# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Gender
      # Defines female variable and associated subquery.
      class Female < Default
        def label
          'Female'
        end

        def variable_name
          'ciw_sex'
        end

        def subquery
          "NULLIF(response, '')::numeric = 2"
        end
      end
    end
  end
end
