# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module ScreenFailures
      # Defines with known medical condition variable and associated subquery.
      class KnownCondAirway < Default
        def label
          'With known medical condition'
        end

        def variable_name
          'ciw_known_cond_airway'
        end

        def subquery
          "NULLIF(response, '')::numeric = 1"
        end
      end
    end
  end
end
