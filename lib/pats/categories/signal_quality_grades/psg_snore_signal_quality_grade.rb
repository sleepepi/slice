# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module SignalQualityGrades
      # Defines PSG Snore Signal Quality Grade Mean
      class PSGSnoreSignalQualityGrade < Default
        def label
          'Snore Signal Quality Grade'
        end

        # 'psg_snore_signal_quality_grade'
        def variable_id
          13263
        end

        def subquery
          "#{database_value} IN (1, 2, 3, 4, 5)"
        end
      end
    end
  end
end
