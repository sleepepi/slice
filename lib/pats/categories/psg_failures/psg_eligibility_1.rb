# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module PSGFailures
      # Defines PSG Eligibility Failure
      class PSGEligibility1 < Default
        def label
          'Obstructive Apnea Index (OAI) >= 1'
        end

        def variable_name
          'ciw_psg_eligibility_not_met_yes'
        end

        def subquery
          "NULLIF(value, '')::numeric = 1"
        end
      end
    end
  end
end
