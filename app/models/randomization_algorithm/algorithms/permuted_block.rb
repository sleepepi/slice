# frozen_string_literal: true

module RandomizationAlgorithm
  module Algorithms
    # Handles list creation and randomization for permuted block randomization
    # schemes.
    class PermutedBlock < StratifiedLists
      attr_reader :randomization_scheme

      def randomization_error_message
        "Block size multipliers and treatment arms may not be set up correctly."
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
