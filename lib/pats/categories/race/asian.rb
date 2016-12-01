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

        def variable_name
          'ciw_race_cat_single'
        end

        def subquery
          "#{database_value} = 4"
        end
      end
    end
  end
end
