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
        [['Female', "NULLIF(response, '')::numeric = 2"], ['Male', "NULLIF(response, '')::numeric = 1"], ['Unknown or not reported', "response = '' or response IS NULL", 'lighter']]
      end
    end
  end
end
