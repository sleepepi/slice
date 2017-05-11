# frozen_string_literal: true

require 'pats/categories/default'

module Pats
  module Categories
    module SignalQualityGrades
      # Defines PSG Chest Signal Quality Grade Mean
      class PSGChestSignalQualityGrade < Default
        def label
          'Chest Signal Quality Grade'
        end

        # 'psg_chest_signal_quality_grade'
        def variable_id
          13378
        end

        def subquery
          "#{database_value} IN (1, 2, 3, 4, 5)"
        end
      end
    end
  end
end
