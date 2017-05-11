# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module PSGOverallStudyQualities
      # Defines PSG Overall Study Quality
      class PSGOverallStudyQuality3 < Default
        def label
          '3: Very Good'
        end

        # 'psg_overall_study_quality'
        def variable_id
          13521
        end

        def subquery
          "#{database_value} = 3"
        end
      end
    end
  end
end
