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

        # 'ciw_taking_meds'
        def variable_id
          13424
        end

        def subquery
          "#{database_value} = 1"
        end
      end
    end
  end
end
