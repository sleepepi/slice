# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module SignalQualityGrades
      # Defines PSG E1 Signal Quality Grade Mean
      class PSGE1SignalQualityGrade < Default
        def label
          'E1 Signal Quality Grade'
        end

        # 'psg_e1_signal_quality_grade'
        def variable_id
          13158
        end

        def subquery
          "#{database_value} IN (1, 2, 3, 4, 5)"
        end
      end
    end
  end
end
