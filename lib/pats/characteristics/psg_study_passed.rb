# frozen_string_literal: true

require 'pats/characteristics/default'

module Pats
  module Characteristics
    # Defines PSG Overall Study Quality.
    class PSGStudyPassed < Default
      def label
        'PSG Study Passed'
      end

      def categories
        [
          Pats::Categories.for('psg-study-passed-yes', project),
          Pats::Categories.for('psg-study-passed-no', project),
          Pats::Categories.for('psg-study-passed-unknown', project)
        ]
      end
    end
  end
end
