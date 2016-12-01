# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module PSGOverallStudyQualities
      # Defines PSG Overall Study Quality
      class PSGOverallStudyQuality4 < Default
        def label
          '4: Excellent'
        end

        def variable_name
          'psg_overall_study_quality'
        end

        def subquery
          "NULLIF(response, '')::numeric = 4"
        end
      end
    end
  end
end
