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
        [['Black / African American', "NULLIF(value, '')::numeric = 3"], ['Other race', "NULLIF(value, '')::numeric IN (1, 2, 4, 5, 98)"], ['Unknown or not reported', "NULLIF(value, '')::numeric IN (1, 2, 3, 4, 5, 98)", 'lighter', true]]
      end
    end
  end
end
