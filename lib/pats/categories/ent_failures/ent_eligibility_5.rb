# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module ENTFailures
      # Defines ENT Eligibility Failure
      class ENTEligibility5 < Default
        def label
          'Evaluation by non-PATS ENT'
        end

        def variable_name
          'ciw_ent_eligibility_not_met_yes'
        end

        def subquery
          "#{database_value} = 5"
        end
      end
    end
  end
end
