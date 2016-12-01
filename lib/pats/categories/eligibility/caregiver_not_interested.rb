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

        def variable_name
          'ciw_eligible_for_baseline'
        end

        def subquery
          "#{database_value} = 2"
        end
      end
    end
  end
end
