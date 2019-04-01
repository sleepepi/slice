# frozen_string_literal: true

module RandomizationAlgorithm
  module Algorithms
    # Handles list creation and randomization for minimization randomization
    # schemes.
    class OneListOrListsBySite < Default
      def add_missing_lists!(current_user)
        if stratify_lists_by_site?
          list_option_ids = []
          if number_of_lists.in?(1..RandomizationScheme::MAX_LISTS - 1)
            list_option_ids = @randomization_scheme.stratification_factors
                                                   .find_by(stratifies_by_site: true)
                                                   .option_hashes.collect { |i| [i] }
          end
          list_option_ids.each do |option_hashes|
            next if find_list_by_option_hashes(option_hashes)
            extra_options = option_hashes.select { |oh| oh[:extra] }
            @randomization_scheme.lists.create(
              project: @randomization_scheme.project,
              user: current_user,
              extra_options: extra_options
            )
          end
        elsif @randomization_scheme.lists.count.zero? && number_of_lists.in?(1..RandomizationScheme::MAX_LISTS - 1)
          @randomization_scheme.lists.create(project: @randomization_scheme.project, user: current_user)
        end
        true
      end

      def number_of_lists
        if stratify_lists_by_site?
          @randomization_scheme.project.sites.count
        else
          super
        end
      end

      def find_list_by_criteria_pairs(criteria_pairs)
        if stratify_lists_by_site?
          site_only_criteria_pairs = criteria_pairs.select do |stratification_factor_id, _option_id|
            @randomization_scheme.stratification_factors.where(id: stratification_factor_id, stratifies_by_site: true).count == 1
          end
          list = nil
          @randomization_scheme.lists.each do |l|
            if l.criteria_match?(site_only_criteria_pairs)
              list = l
              break
            end
          end
          list
        else
          super
        end
      end

      def stratify_lists_by_site?
        @randomization_scheme.stratification_factors.where(stratifies_by_site: true).count.positive?
      end
    end
  end
end
