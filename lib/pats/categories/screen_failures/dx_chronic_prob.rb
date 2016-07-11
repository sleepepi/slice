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

        def variable_name
          'ciw_dx_chronic_prob'
        end

        def subquery
          "NULLIF(response, '')::numeric = 1"
        end
      end
    end
  end
end
