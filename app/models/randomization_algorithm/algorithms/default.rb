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


    end

  end

end
