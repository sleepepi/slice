# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module PSGOverallStudyQualities
      # Defines PSG Overall Study Quality
      class PSGOverallStudyQuality2 < Default
        def label
          '2: Good'
        end

        def variable_name
          'psg_overall_study_quality'
        end

        def subquery
          "#{database_value} = 2"
        end
      end
    end
  end
end
