# frozen_string_literal: true

require 'pats/characteristics/default'

module Pats
  module Characteristics
    # Defines PSG Overall Study Quality.
    class SignalQualityGrades < Default
      def label
        'Signal Quality Grades'
      end

      def categories
        [
          Pats::Categories.for('psg-e1-signal-quality-grade', project),
          Pats::Categories.for('psg-snore-signal-quality-grade', project),
          Pats::Categories.for('psg-chest-signal-quality-grade', project),
          Pats::Categories.for('psg-cap-signal-quality-grade', project)
        ]
      end
    end
  end
end
