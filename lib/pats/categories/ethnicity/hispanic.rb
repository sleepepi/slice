# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Ethnicity
      # Defines hispanic variable and associated subquery.
      class Hispanic < Default
        def label
          'Hispanic or Latino'
        end

        def variable_name
          'ciw_ethnicity'
        end

        def subquery
          "#{database_value} = 1"
        end
      end
    end
  end
end
