# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module PSGFailures
      # Defines PSG Eligibility Failure
      class PSGEligibility3 < Default
        def label
          'SpO2 desaturations < 90% with obstructive events'
        end

        # 'ciw_psg_eligibility_not_met_yes'
        def variable_id
          14327
        end

        def subquery
          "#{database_value} = 3"
        end
      end
    end
  end
end
