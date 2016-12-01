# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module PSGStudyPassed
      # Defines PSG Study Passed
      class PSGStudyPassedUnknown < Default
        def label
          'Unknown or not reported'
        end

        def variable_name
          'psg_study_passed'
        end

        def subquery
          "#{database_value} IN (0, 1)"
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
