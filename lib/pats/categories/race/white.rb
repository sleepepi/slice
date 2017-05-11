# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Race
      # Defines white race variable.
      class White < Default
        def label
          'White / Caucasian'
        end

        # 'ciw_race_cat_single'
        def variable_id
          15882
        end

        def subquery
          "#{database_value} = 2"
        end
      end
    end
  end
end
