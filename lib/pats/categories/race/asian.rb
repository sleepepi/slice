# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Race
      # Defines Asian race variable.
      class Asian < Default
        def label
          'Asian'
        end

        # 'ciw_race_cat_single'
        def variable_id
          15882
        end

        def subquery
          "#{database_value} = 4"
        end
      end
    end
  end
end
