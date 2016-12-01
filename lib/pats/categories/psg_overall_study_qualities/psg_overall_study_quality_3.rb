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

        def variable_name
          'psg_overall_study_quality'
        end

        def subquery
          "NULLIF(response, '')::numeric = 3"
        end
      end
    end
  end
end
