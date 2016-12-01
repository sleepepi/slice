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

        def variable_name
          'ciw_race_cat_single'
        end

        def subquery
          "#{database_value} = 1"
        end
      end
    end
  end
end
