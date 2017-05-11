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

        # 'ciw_previous_osa_diagnosis'
        def variable_id
          14593
        end

        def subquery
          "#{database_value} = 1"
        end
      end
    end
  end
end
