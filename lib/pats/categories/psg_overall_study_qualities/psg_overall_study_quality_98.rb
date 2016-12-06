# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module PSGOverallStudyQualities
      # Defines PSG Overall Study Quality
      class PSGOverallStudyQuality98 < Default
        def label
          '98: Other'
        end

        def variable_name
          'psg_overall_study_quality'
        end

        def subquery
          "#{database_value} = 98"
        end
      end
    end
  end
end
