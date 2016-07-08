# frozen_string_literal: true

require 'pats/characteristics/default'

module Pats
  module Characteristics
    # Defines age and associated categories and subqueries.
    class Age < Default
      def label
        'Age'
      end

      def variable_name
        'ciw_age_years'
      end

      def categories
        [
          {
            label: '3 or 4 years old',
            subquery: "NULLIF(response, '')::numeric >= 3 and NULLIF(response, '')::numeric < 5"
          },
          {
            label: '5 or 6 years old',
            subquery: "NULLIF(response, '')::numeric >= 5 and NULLIF(response, '')::numeric < 7"
          },
          {
            label: '7 years or older',
            subquery: "NULLIF(response, '')::numeric >= 7"
          },
          {
            label: 'Unknown or not reported',
            subquery: "response = '' or response IS NULL",
            css_class: 'lighter'
          }
        ]
      end
    end
  end
end
