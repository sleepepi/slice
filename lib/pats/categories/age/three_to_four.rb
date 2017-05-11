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

        # 'ciw_age_years'
        def variable_id
          13416
        end

        def subquery
          "#{database_value} >= 3 and #{database_value} < 5"
        end
      end
    end
  end
end
