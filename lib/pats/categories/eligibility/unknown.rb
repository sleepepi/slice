# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module Eligibility
      # Defines unknown eligibility variable and associated subquery.
      class Unknown < Default
        def label
          'Total Pending Eligibility Determination'
        end

        # 'ciw_eligible_for_baseline'
        def variable_id
          14299
        end

        def subquery
          "#{database_value} IS NULL"
        end

        def css_class
          'lighter'
        end
      end
    end
  end
end
