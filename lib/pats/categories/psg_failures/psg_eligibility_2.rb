# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module PSGFailures
      # Defines PSG Eligibility Failure
      class PSGEligibility2 < Default
        def label
          'Apnea-Hypopnea Index (AHI) >= 2'
        end

        def variable_name
          'ciw_psg_eligibility_not_met_yes'
        end

        def subquery
          "NULLIF(value, '')::numeric = 2"
        end
      end
    end
  end
end
