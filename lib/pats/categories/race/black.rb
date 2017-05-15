# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Race
      # Defines black race variable.
      class Black < Default
        def label
          'Black / African American'
        end

        # 'ciw_race_cat_single'
        def variable_id
          15882
        end

        def subquery
          "#{database_value} = 1"
        end
      end
    end
  end
end
