# frozen_string_literal: true

require 'pats/characteristics/default'

module Pats
  module Characteristics
    # Defines screen failures for PSG eligibility.
    class PSGFailures < Default
      def label
        'PSG requirement not met'
      end

      def categories
        [
          Pats::Categories.for('psg-eligibility-not-met', project),
          Pats::Categories.for('psg-eligibility-failure-1', project),
          Pats::Categories.for('psg-eligibility-failure-2', project),
          Pats::Categories.for('psg-eligibility-failure-3', project),
          Pats::Categories.for('psg-eligibility-failure-4', project)
        ]
      end
    end
  end
end
