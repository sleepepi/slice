# frozen_string_literal: true

module RandomizationAlgorithm
  module Algorithms
    # Handles list creation and randomization for algorithms using stratified
    # lists.
    class StratifiedLists < Default
      def add_missing_lists!(current_user)
        stratifications = []

        if number_of_lists.in?(1..RandomizationScheme::MAX_LISTS - 1)
          stratifications = [[]]
          @randomization_scheme.stratification_factors.each do |stratification_factor|
            stratifications = stratifications.product(stratification_factor.option_hashes)
          end
          stratifications.collect!(&:flatten)
        else
          return false
        end

        stratifications.each do |option_hashes|
          next if find_list_by_option_hashes(option_hashes)
          stratification_factor_option_ids = option_hashes.collect { |oh| oh[:stratification_factor_option_id] }
          options = @randomization_scheme.stratification_factor_options.where(id: stratification_factor_option_ids)
          extra_options = option_hashes.select { |oh| oh[:extra] }
          @randomization_scheme.lists.create(
            project: @randomization_scheme.project,
            user: current_user,
            options: options,
            extra_options: extra_options
          )
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
    end
  end
end
