# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module PSGFailures
      # Defines PSG Eligibility Failure
      class PSGEligibility4 < Default
        def label
          'ECG alert'
        end

        # 'ciw_psg_eligibility_not_met_yes'
        def variable_id
          14327
        end

        def subquery
          "#{database_value} = 4"
        end
      end
    end
  end
end
