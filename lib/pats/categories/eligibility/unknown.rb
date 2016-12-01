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

        def variable_name
          'ciw_eligible_for_baseline'
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
