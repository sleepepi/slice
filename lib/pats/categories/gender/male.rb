# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Gender
      # Defines male variable and associated subquery.
      class Male < Default
        def label
          'Male'
        end

        def variable_name
          'ciw_sex'
        end

        def subquery
          "#{database_value} = 1"
        end
      end
    end
  end
end
