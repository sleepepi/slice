# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module ScreenFailures
      # Defines taking meds variable and associated subquery.
      class TakingMeds < Default
        def label
          'Taking study-restricted medication'
        end

        def variable_name
          'ciw_taking_meds'
        end

        def subquery
          "NULLIF(response, '')::numeric = 1"
        end
      end
    end
  end
end
