# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Ethnicity
      # Defines unknown ethnicity variable and associated subquery.
      class Unknown < Default
        def label
          'Unknown or not reported'
        end

        def variable_name
          'ciw_ethnicity'
        end

        def subquery
          "#{database_value} IS NULL"
        end

        def css_class
          'lighter'
        end
      end
    end
  end
end
