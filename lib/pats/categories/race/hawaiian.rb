# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Race
      # Defines Native Hawaiian / Other Pacific Islander race variable.
      class Hawaiian < Default
        def label
          'Native Hawaiian / Other Pacific Islander'
        end

        # 'ciw_race_cat_single'
        def variable_id
          15882
        end

        def subquery
          "#{database_value} = 5"
        end
      end
    end
  end
end
