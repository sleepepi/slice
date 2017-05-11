# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Race
      # Defines unknown race variable and associated subquery.
      class Unknown < Default
        def label
          'Unknown or not reported'
        end

        # 'ciw_race_cat_single'
        def variable_id
          15882
        end

        def subquery
          "#{database_value} IN (1, 2, 3, 4, 5, 6)"
        end

        def css_class
          'lighter'
        end

        def inverse
          true
        end
      end
    end
  end
end
