# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Age
      # Defines unknown age variable and associated subquery.
      class Unknown < Default
        def label
          'Unknown or not reported'
        end

        def variable_name
          'ciw_age_years'
        end

        def subquery
          "response = '' or response IS NULL"
        end

        def css_class
          'lighter'
        end
      end
    end
  end
end
