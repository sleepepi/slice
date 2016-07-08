# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Race
      # Defines black race variable and associated subquery.
      class Black < Default
        def label
          'Black'
        end

        def variable_name
          'ciw_race'
        end

        def subquery
          "NULLIF(value, '')::numeric = 3"
        end
      end
    end
  end
end
