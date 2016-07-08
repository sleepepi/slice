# frozen_string_literal: true

require 'pats/characteristics/default'

module Pats
  module Characteristics
    # Defines ethnicity and associated categories and subqueries.
    class Ethnicity < Default
      attr_reader :project

      def label
        'Ethnicity'
      end

      def variable_name
        'ciw_ethnicity'
      end

      def categories
        [
          {
            label: 'Hispanic or Latino',
            subquery: "NULLIF(response, '')::numeric = 1"
          },
          {
            label: 'Not Hispanic or Latino',
            subquery: "NULLIF(response, '')::numeric = 2"
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
