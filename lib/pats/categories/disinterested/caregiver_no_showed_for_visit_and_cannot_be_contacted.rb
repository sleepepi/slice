# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Disinterested
      # Defines caregiver no-showed for visit and cannot be contacted variable and associated subquery.
      class CaregiverNoShowedForVisitAndCannotBeContacted < Default
        def label
          'Caregiver no-showed for visit and cannot be contacted'
        end

        def variable_name
          'ciw_cg_reason_not_interested'
        end

        def subquery
          "#{database_value} = 10"
        end
      end
    end
  end
end
