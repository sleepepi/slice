# frozen_string_literal: true

require 'pats/characteristics/default'

module Pats
  module Characteristics
    # Defines age and associated categories and subqueries.
    class Age < Default
      attr_reader :project

      def label
        'Age'
      end

      def variable_name
        'ciw_age_years'
      end

      def categories
        [['3 or 4 years old', "NULLIF(response, '')::numeric >= 3 and NULLIF(response, '')::numeric < 5"], ['5 or 6 years old', "NULLIF(response, '')::numeric >= 5 and NULLIF(response, '')::numeric < 7"], ['7 years or older', "NULLIF(response, '')::numeric >= 7"], ['Unknown or not reported', "response = '' or response IS NULL", 'lighter']]
      end
    end
  end
end
