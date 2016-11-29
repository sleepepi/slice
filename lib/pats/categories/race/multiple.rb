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

        def variable_name
          'ciw_race_cat_single'
        end

        def subquery
          "NULLIF(response, '')::numeric = 6"
        end
      end
    end
  end
end
