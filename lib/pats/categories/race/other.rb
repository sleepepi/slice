# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Race
      # Defines other race variable and associated subquery.
      class Other < Default
        def label
          'Other race'
        end

        def variable_name
          'ciw_race'
        end

        def subquery
          "NULLIF(value, '')::numeric IN (1, 2, 4, 5, 98)"
        end
      end
    end
  end
end
