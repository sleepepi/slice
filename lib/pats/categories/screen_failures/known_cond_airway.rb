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

        # 'ciw_known_cond_airway'
        def variable_id
          13411
        end

        def subquery
          "#{database_value} = 1"
        end
      end
    end
  end
end
