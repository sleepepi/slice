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
        [['Hispanic or Latino', "NULLIF(response, '')::numeric = 1"], ['Not Hispanic or Latino', "NULLIF(response, '')::numeric = 2"], ['Unknown or not reported', "response = '' or response IS NULL", 'lighter']]
      end
    end
  end
end
