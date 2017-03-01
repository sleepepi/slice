# frozen_string_literal: true

module RandomizationAlgorithm
  module Algorithms
    # Handles list creation and randomization for permuted block randomization
    # schemes.
    class PermutedBlock < Default
      attr_reader :randomization_scheme

      def initialize(randomization_scheme)
        @randomization_scheme = randomization_scheme
      end

      def randomization_error_message
        'Block Size Multipliers and Treatment Arms may not be set up correctly.'
      end

      def add_missing_lists!(current_user)
        stratifications = []

        if number_of_lists > 0 && number_of_lists < RandomizationScheme::MAX_LISTS
          stratifications = [[]]
          @randomization_scheme.stratification_factors.each do |stratification_factor|
            stratifications = stratifications.product(stratification_factor.option_hashes)
          end
          stratifications.collect!(&:flatten)
        end

        stratifications.each do |option_hashes|
          unless find_list_by_option_hashes(option_hashes)
            stratification_factor_option_ids = option_hashes.collect { |oh| oh[:stratification_factor_option_id] }
            options = @randomization_scheme.stratification_factor_options.where(id: stratification_factor_option_ids)
            extra_options = option_hashes.select { |oh| oh[:extra] }
            @randomization_scheme.lists.create(
              project_id: @randomization_scheme.project_id,
              user_id: current_user.id,
              options: options,
              extra_options: extra_options
            )
          end
        end
      end

      def number_of_lists
        @randomization_scheme.stratification_factors.collect { |sf| sf.option_hashes.count }.inject(:*).to_i
      end

      def find_list_by_criteria_pairs(criteria_pairs)
        list = nil
        @randomization_scheme.lists.each do |l|
          if l.criteria_match?(criteria_pairs)
            list = l
            break
          end
        end
        list
      end

      def randomize_subject_to_list!(subject, list, current_user, criteria_pairs)
        # Find next randomization in list
        randomization = list.randomizations.where(subject_id: nil).order(:position).first

        # Expand lists by another block group
        unless randomization
          max_needed_block_group = [next_block_group - 1, list.next_block_group].max
          generate_next_block_group_up_to!(current_user, max_needed_block_group)
          randomization = list.randomizations.where(subject_id: nil).order(:position).first
        end
        if randomization
          randomization.add_subject!(subject, current_user)
          add_randomization_characteristics!(randomization, criteria_pairs)
        end
        randomization
      end

      protected

      def generate_next_block_group_up_to!(current_user, block_group)
        multipliers = @randomization_scheme.block_size_multipliers.collect { |m| [m.value] * m.allocation }.flatten
        arms        = @randomization_scheme.treatment_arms.collect { |arm| [arm.id] * arm.allocation }.flatten
        @randomization_scheme.lists.each do |list|
          list.generate_all_block_groups_up_to!(current_user, block_group, multipliers, arms)
        end
      end

      def next_block_group
        (@randomization_scheme.randomizations.pluck(:block_group).max || 0) + 1
      end
    end
  end
end
