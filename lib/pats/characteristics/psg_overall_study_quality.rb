# frozen_string_literal: true

require 'pats/characteristics/default'

module Pats
  module Characteristics
    # Defines PSG Overall Study Quality.
    class PSGOverallStudyQuality < Default
      def label
        'PSG Overall Study Quality'
      end

      def categories
        [
          Pats::Categories.for('psg-5-outstanding', project),
          Pats::Categories.for('psg-4-excellent', project),
          Pats::Categories.for('psg-3-very-good', project),
          Pats::Categories.for('psg-2-good', project),
          Pats::Categories.for('psg-1-fair', project),
          Pats::Categories.for('psg-0-failed', project),
          Pats::Categories.for('psg-unknown', project)
        ]
      end
    end
  end
end
