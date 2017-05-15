# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Eligibility
      # Defines caregiver not interested variable and associated subquery.
      class CaregiverNotInterested < Default
        def label
          'Caregiver Not Interested'
        end

        # 'ciw_eligible_for_baseline'
        def variable_id
          14299
        end

        def subquery
          "#{database_value} = 2"
        end
      end
    end
  end
end
