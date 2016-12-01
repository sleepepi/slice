# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module ScreenFailures
      # Defines previous upper airway surgery variable and associated subquery.
      class PrevUpperAirwaySurgery < Default
        def label
          'Previous upper airway surgery'
        end

        def variable_name
          'ciw_prev_upper_airway_surgery'
        end

        def subquery
          "#{database_value} = 1"
        end
      end
    end
  end
end
