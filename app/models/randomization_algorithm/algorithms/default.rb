module RandomizationAlgorithm

  module Algorithms

    class Default

      attr_reader :randomization_scheme

      def initialize(randomization_scheme)
        @randomization_scheme = randomization_scheme
      end

      def randomization_error_message
        "Treatment Arms may not be set up correctly."
      end

      def add_missing_lists!(current_user)
        #
      end

      def number_of_lists
        1
      end

      def find_list_by_option_hashes(option_hashes)
        criteria_pairs = option_hashes.collect{|h| [h[:stratification_factor_id], (h[:stratification_factor_option_id] || h[:site_id])]}
        self.find_list_by_criteria_pairs(criteria_pairs)
      end

      def find_list_by_criteria_pairs(criteria_pairs)
        @randomization_scheme.lists.first
      end

      def add_randomization_characteristics!(randomization, criteria_pairs)
        @randomization_scheme.stratification_factors.each do |sf|
          if criteria = criteria_pairs.select{|sfid, oid| sfid == sf.id}.first
            if sf.stratifies_by_site?
              randomization.randomization_characteristics.create(
                project_id: @randomization_scheme.project_id,
                randomization_scheme_id: @randomization_scheme.id,
                list_id: randomization.list_id,
                stratification_factor_id: sf.id,
                site_id: @randomization_scheme.project.sites.where(id: criteria.last).pluck(:id).first
              )
            else
              randomization.randomization_characteristics.create(
                project_id: @randomization_scheme.project_id,
                randomization_scheme_id: @randomization_scheme.id,
                list_id: randomization.list_id,
                stratification_factor_id: sf.id,
                stratification_factor_option_id: sf.stratification_factor_options.where(id: criteria.last).pluck(:id).first
              )
            end
          end
        end
      end

    end

  end

end
