# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Eligibility
      # Defines fully eligible variable and associated subquery.
      class FullyEligible < Default
        def label
          'Fully Eligible'
        end

        # 'ciw_eligible_for_baseline'
        def variable_id
          14299
        end

        def subquery
          "#{database_value} = 1"
        end
      end
    end
  end
end
