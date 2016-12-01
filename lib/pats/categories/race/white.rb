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

        def variable_name
          'ciw_race_cat_single'
        end

        def subquery
          "#{database_value} = 2"
        end
      end
    end
  end
end
