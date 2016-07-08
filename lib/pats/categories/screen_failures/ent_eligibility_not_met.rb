# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module ScreenFailures
      # Defines ent requirement not met variable and associated subquery.
      class EntEligibilityNotMet < Default
        def label
          'ENT requirement not met'
        end

        def variable_name
          'ciw_ent_eligibility_not_met'
        end

        def subquery
          "NULLIF(response, '')::numeric = 1"
        end
      end
    end
  end
end
