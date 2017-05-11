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

        # 'psg_overall_study_quality'
        def variable_id
          13521
        end

        def subquery
          "#{database_value} IN (1, 2, 3, 4, 5, 98)"
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
