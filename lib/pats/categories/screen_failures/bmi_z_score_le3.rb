# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module ScreenFailures
      # Defines bmi z-score variable and associated subquery.
      class BmiZScoreLe3 < Default
        def label
          'BMI z-score > 3'
        end

        # 'ciw_bmi_z_score_le3'
        def variable_id
          13392
        end

        def subquery
          "#{database_value} = 0"
        end
      end
    end
  end
end
