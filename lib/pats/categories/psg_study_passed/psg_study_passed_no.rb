# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module PSGStudyPassed
      # Defines PSG Study Passed
      class PSGStudyPassedNo < Default
        def label
          '0: No'
        end

        def variable_name
          'psg_study_passed'
        end

        def subquery
          "#{database_value} = 0"
        end
      end
    end
  end
end
