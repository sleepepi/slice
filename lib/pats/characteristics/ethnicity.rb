# frozen_string_literal: true

require 'pats/characteristics/default'

module Pats
  module Characteristics
    # Defines ethnicity and associated categories and subqueries.
    class Ethnicity < Default
      def label
        'Ethnicity'
      end

      def variable_name
        'ciw_ethnicity'
      end

      def categories
        [
          Pats::Categories.for('hispanic', project),
          Pats::Categories.for('not-hispanic', project),
          Pats::Categories.for('ethnicity-unknown', project)
        ]
      end
    end
  end
end
