# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module ScreenFailures
      # Defines parent report snoring variable and associated subquery.
      class ParentReportSnoring < Default
        def label
          'Child does not snore regularly'
        end

        def variable_name
          'ciw_parent_report_snoring'
        end

        def subquery
          "NULLIF(response, '')::numeric = 0"
        end
      end
    end
  end
end
