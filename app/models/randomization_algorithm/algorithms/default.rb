# frozen_string_literal: true

module RandomizationAlgorithm
  module Algorithms

    class Default
      attr_reader :randomization_scheme

      def initialize(randomization_scheme)
        @randomization_scheme = randomization_scheme
      end

      def randomization_error_message
        "Treatment arms may not be set up correctly."
      end

      def add_missing_lists!(current_user)
        true
      end

      def number_of_lists
        1
      end

      def find_list_by_option_hashes(option_hashes)
        criteria_pairs = option_hashes.collect do |h|
          [
            h[:stratification_factor_id],
            (h[:stratification_factor_option_id] || h[:site_id])
          ]
        end
        find_list_by_criteria_pairs(criteria_pairs)
      end

      def find_list_by_criteria_pairs(_criteria_pairs)
        @randomization_scheme.lists.first
      end

      def add_randomization_characteristics!(randomization, criteria_pairs)
        @randomization_scheme.stratification_factors.each do |sf|
          criteria = criteria_pairs.find { |sfid, _oid| sfid == sf.id }
          next unless criteria
          if sf.stratifies_by_site?
            randomization.randomization_characteristics.create(
              project_id: @randomization_scheme.project_id,
              randomization_scheme_id: @randomization_scheme.id,
              list_id: randomization.list_id,
              site_id: randomization.subject.site_id,
              stratification_factor_id: sf.id
            )
          else
            randomization.randomization_characteristics.create(
              project_id: @randomization_scheme.project_id,
              randomization_scheme_id: @randomization_scheme.id,
              list_id: randomization.list_id,
              site_id: randomization.subject.site_id,
              stratification_factor_id: sf.id,
              stratification_factor_option_id: sf.stratification_factor_options.where(id: criteria.last).pluck(:id).first
            )
          end
        end
      end

      def all_criteria_selected?(criteria_pairs)
        criteria_pairs.collect! { |sfid, oid| [sfid.to_i, oid.to_i] }
        @randomization_scheme.stratification_factors.each do |sf|
          if criteria_pairs.count { |sfid, oid| sfid == sf.id && oid.in?(sf.valid_values) }.zero?
            # Return if not all criteria pairs are selected
            return false
          end
        end
        true
      end
    end
  end
end
