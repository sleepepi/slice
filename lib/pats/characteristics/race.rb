# frozen_string_literal: true

require 'pats/characteristics/default'

module Pats
  module Characteristics
    # Defines race and associated categories and subqueries.
    class Race < Default
      def label
        'Race'
      end

      # 'ciw_race_cat_single'
      def variable_id
        15882
      end

      def categories
        [
          Pats::Categories.for('black-race', project),
          Pats::Categories.for('white-race', project),
          Pats::Categories.for('american-indian-race', project),
          Pats::Categories.for('asian-race', project),
          Pats::Categories.for('hawaiian-race', project),
          Pats::Categories.for('multiple-race', project),
          Pats::Categories.for('unknown-race', project)
        ]
      end
    end
  end
end
