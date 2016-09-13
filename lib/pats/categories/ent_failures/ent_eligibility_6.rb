# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module ENTFailures
      # Defines ENT Eligibility Failure
      class ENTEligibility6 < Default
        def label
          'Physician did not provide approval for contact'
        end

        def variable_name
          'ciw_ent_eligibility_not_met_yes'
        end

        def subquery
          "NULLIF(value, '')::numeric = 6"
        end
      end
    end
  end
end
