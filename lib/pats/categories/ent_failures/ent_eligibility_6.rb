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

        # 'ciw_ent_eligibility_not_met_yes'
        def variable_id
          14326
        end

        def subquery
          "#{database_value} = 6"
        end
      end
    end
  end
end
