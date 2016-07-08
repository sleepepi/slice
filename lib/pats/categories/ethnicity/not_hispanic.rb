# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Ethnicity
      # Defines not hispanic variable and associated subquery.
      class NotHispanic < Default
        def label
          'Not Hispanic or Latino'
        end

        def variable_name
          'ciw_ethnicity'
        end

        def subquery
          "NULLIF(response, '')::numeric = 2"
        end
      end
    end
  end
end
