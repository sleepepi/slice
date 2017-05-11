# frozen_string_literal: true

require 'pats/characteristics/default'

module Pats
  module Characteristics
    # Defines gender and associated categories and subqueries.
    class Gender < Default
      def label
        'Gender'
      end

      # 'ciw_sex'
      def variable_id
        13419
      end

      def categories
        [
          Pats::Categories.for('female', project),
          Pats::Categories.for('male', project),
          Pats::Categories.for('gender-unknown', project)
        ]
      end
    end
  end
end
