# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Eligibility
      # Defines ineligible variable and associated subquery.
      class Ineligible < Default
        def label
          'Total Screen Failures'
        end

        # 'ciw_eligible_for_baseline'
        def variable_id
          14299
        end

        def subquery
          "#{database_value} = 0"
        end
      end
    end
  end
end
