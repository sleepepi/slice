# frozen_string_literal: true

require 'pats/characteristics/default'

module Pats
  module Characteristics
    # Defines race and associated categories and subqueries.
    class Race < Default
      attr_reader :project

      def label
        'Race'
      end

      def variable_name
        'ciw_race'
      end

      def categories
        [
          {
            label: 'Black / African American',
            subquery: "NULLIF(value, '')::numeric = 3"
          },
          {
            label: 'Other race',
            subquery: "NULLIF(value, '')::numeric IN (1, 2, 4, 5, 98)"
          },
          {
            label: 'Unknown or not reported',
            subquery: "NULLIF(value, '')::numeric IN (1, 2, 3, 4, 5, 98)",
            css_class: 'lighter',
            inverse: true
          }
        ]
      end
    end
  end
end
