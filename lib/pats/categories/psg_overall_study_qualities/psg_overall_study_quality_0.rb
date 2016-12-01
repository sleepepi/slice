# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module PSGOverallStudyQualities
      # Defines PSG Overall Study Quality
      class PSGOverallStudyQuality0 < Default
        def label
          '0: Failed'
        end

        def variable_name
          'psg_overall_study_quality'
        end

        def subquery
          "NULLIF(response, '')::numeric = 0"
        end
      end
    end
  end
end
