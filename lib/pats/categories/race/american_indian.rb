# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Race
      # Defines American Indian / Native Alaskan race variable.
      class AmericanIndian < Default
        def label
          'American Indian / Native Alaskan'
        end

        # 'ciw_race_cat_single'
        def variable_id
          15882
        end

        def subquery
          "#{database_value} = 3"
        end
      end
    end
  end
end
