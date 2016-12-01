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

        def variable_name
          'ciw_race_cat_single'
        end

        def subquery
          "#{database_value} = 5"
        end
      end
    end
  end
end
