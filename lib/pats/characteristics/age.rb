# frozen_string_literal: true

require 'pats/characteristics/default'

module Pats
  module Characteristics
    # Defines age and associated categories and subqueries.
    class Age < Default
      def label
        'Age'
      end

      # 'ciw_age_years'
      def variable_id
        13416
      end

      def categories
        [
          Pats::Categories.for('age-3to4', project),
          Pats::Categories.for('age-5to6', project),
          Pats::Categories.for('age-7plus', project),
          Pats::Categories.for('age-unknown', project)
        ]
      end
    end
  end
end
