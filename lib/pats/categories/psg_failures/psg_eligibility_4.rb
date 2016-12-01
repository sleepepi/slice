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

        def variable_name
          'ciw_psg_eligibility_not_met_yes'
        end

        def subquery
          "#{database_value} = 4"
        end
      end
    end
  end
end
