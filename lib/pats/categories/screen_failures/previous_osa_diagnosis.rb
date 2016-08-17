# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module ScreenFailures
      # Defines previous OSA diagnosis variable and associated subquery.
      class PreviousOSADiagnosis < Default
        def label
          'Previous OSA diagnosis'
        end

        def variable_name
          'ciw_previous_osa_diagnosis'
        end

        def subquery
          "NULLIF(response, '')::numeric = 1"
        end
      end
    end
  end
end
