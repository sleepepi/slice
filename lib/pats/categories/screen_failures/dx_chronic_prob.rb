# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module ScreenFailures
      # Defines chronic health problem variable and associated subquery.
      class DxChronicProb < Default
        def label
          'Severe, chronic health problem'
        end

        # 'ciw_dx_chronic_prob'
        def variable_id
          14295
        end

        def subquery
          "#{database_value} = 1"
        end
      end
    end
  end
end
