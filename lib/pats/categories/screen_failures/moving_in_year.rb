# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module ScreenFailures
      # Defines moving in year variable and associated subquery.
      class MovingInYear < Default
        def label
          "Child's family plans to move within the year"
        end

        def variable_name
          'ciw_moving_in_year'
        end

        def subquery
          "#{database_value} = 1"
        end
      end
    end
  end
end
