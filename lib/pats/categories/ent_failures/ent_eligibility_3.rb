# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module ENTFailures
      # Defines ENT Eligibility Failure
      class ENTEligibility3 < Default
        def label
          'ENT decided child is not a good candidate for AT'
        end

        def variable_name
          'ciw_ent_eligibility_not_met_yes'
        end

        def subquery
          "NULLIF(value, '')::numeric = 3"
        end
      end
    end
  end
end