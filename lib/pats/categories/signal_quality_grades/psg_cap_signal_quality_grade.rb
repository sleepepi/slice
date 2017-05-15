# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module SignalQualityGrades
      # Defines PSG Cap Signal Quality Grade Mean
      class PSGCapSignalQualityGrade < Default
        def label
          'Cap Signal Quality Grade'
        end

        # 'psg_cap_signal_quality_grade'
        def variable_id
          13418
        end

        def subquery
          "#{database_value} IN (1, 2, 3, 4, 5)"
        end
      end
    end
  end
end
