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

        # 'ciw_parent_report_snoring'
        def variable_id
          14294
        end

        def subquery
          "#{database_value} = 0"
        end
      end
    end
  end
end
