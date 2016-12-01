# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module PSGOverallStudyQualities
      # Defines PSG Overall Study Quality
      class PSGOverallStudyQualityUnknown < Default
        def label
          'Unknown or not reported'
        end

        def variable_name
          'psg_overall_study_quality'
        end

        def subquery
          "NULLIF(response, '')::numeric IN (0, 1, 2, 3, 4, 5)"
        end

        def css_class
          'lighter'
        end

        def inverse
          true
        end
      end
    end
  end
end
