# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Disinterested
      # Defines caregiver could not be contacted for eligibility variable and associated subquery.
      class CaregiverCouldNotBeContactedForEligibility < Default
        def label
          'Caregiver could not be contacted for eligibility'
        end

        # 'ciw_cg_reason_not_interested'
        def variable_id
          14301
        end

        def subquery
          "#{database_value} = 9"
        end
      end
    end
  end
end
