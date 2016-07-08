# frozen_string_literal: true

require 'pats/characteristics/default'

module Pats
  module Characteristics
    # Defines gender and associated categories and subqueries.
    class Gender < Default
      attr_reader :project

      def label
        'Gender'
      end

      def variable_name
        'ciw_sex'
      end

      def categories
        [
          {
            label: 'Female',
            subquery: "NULLIF(response, '')::numeric = 2"
          },
          {
            label: 'Male',
            subquery: "NULLIF(response, '')::numeric = 1"
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
