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

        def variable_name
          'ciw_cg_reason_not_interested'
        end

        def subquery
          "NULLIF(value, '')::numeric = 9"
        end
      end
    end
  end
end
