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

        # 'ciw_ent_eligibility_not_met_yes'
        def variable_id
          14326
        end

        def subquery
          "#{database_value} = 3"
        end
      end
    end
  end
end
