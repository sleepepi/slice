# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module ScreenFailures
      # Defines foster care variable and associated subquery.
      class FosterCare < Default
        def label
          'Child is in foster care'
        end

        # 'ciw_foster_care'
        def variable_id
          14166
        end

        def subquery
          "#{database_value} = 1"
        end
      end
    end
  end
end
