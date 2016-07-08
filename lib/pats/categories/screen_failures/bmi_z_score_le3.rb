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

        def variable_name
          'ciw_bmi_z_score_le3'
        end

        def subquery
          "NULLIF(response, '')::numeric = 0"
        end
      end
    end
  end
end
