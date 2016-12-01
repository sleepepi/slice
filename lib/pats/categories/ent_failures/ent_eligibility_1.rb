# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module ENTFailures
      # Defines ENT Eligibility Failure
      class ENTEligibility1 < Default
        def label
          'Tonsil size < 2'
        end

        def variable_name
          'ciw_ent_eligibility_not_met_yes'
        end

        def subquery
          "#{database_value} = 1"
        end
      end
    end
  end
end
