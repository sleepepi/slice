# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Age
      # Defines age from 3 to 4 variable and associated subquery.
      class ThreeToFour < Default
        def label
          '3 or 4 years old'
        end

        def variable_name
          'ciw_age_years'
        end

        def subquery
          "NULLIF(response, '')::numeric >= 3 and NULLIF(response, '')::numeric < 5"
        end
      end
    end
  end
end
