# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Race
      # Defines more than one race variable.
      class Multiple < Default
        def label
          'More than one race'
        end

        # 'ciw_race_cat_single'
        def variable_id
          15882
        end

        def subquery
          "#{database_value} = 6"
        end
      end
    end
  end
end
