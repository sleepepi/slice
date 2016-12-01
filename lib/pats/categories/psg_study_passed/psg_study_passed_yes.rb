# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module PSGStudyPassed
      # Defines PSG Study Passed
      class PSGStudyPassedYes < Default
        def label
          '1: Yes'
        end

        def variable_name
          'psg_study_passed'
        end

        def subquery
          "#{database_value} = 1"
        end
      end
    end
  end
end
