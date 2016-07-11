# frozen_string_literal: true

require 'pats/characteristics/default'

module Pats
  module Characteristics
    # Defines race and associated categories and subqueries.
    class Race < Default
      def label
        'Race'
      end

      def variable_name
        'ciw_race'
      end

      def categories
        [
          Pats::Categories.for('black-race', project),
          Pats::Categories.for('other-race', project),
          Pats::Categories.for('unknown-race', project)
        ]
      end
    end
  end
end
