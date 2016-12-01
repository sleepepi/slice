# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Age
      # Defines age from 5 to 6 variable and associated subquery.
      class FiveToSix < Default
        def label
          '5 or 6 years old'
        end

        def variable_name
          'ciw_age_years'
        end

        def subquery
          "#{database_value} >= 5 and #{database_value} < 7"
        end
      end
    end
  end
end
