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

        def variable_name
          'ciw_eligible_for_baseline'
        end

        def subquery
          "NULLIF(response, '')::numeric = 1"
        end
      end
    end
  end
end
