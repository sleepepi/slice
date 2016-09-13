# frozen_string_literal: true

require 'pats/characteristics/default'

module Pats
  module Characteristics
    # Defines screen failures for ENT eligibility.
    class ENTFailures < Default
      def label
        'ENT requirement not met'
      end

      def categories
        [
          Pats::Categories.for('ent-eligibility-not-met', project),
          Pats::Categories.for('ent-eligibility-failure-1', project),
          Pats::Categories.for('ent-eligibility-failure-2', project),
          Pats::Categories.for('ent-eligibility-failure-3', project),
          Pats::Categories.for('ent-eligibility-failure-4', project),
          Pats::Categories.for('ent-eligibility-failure-5', project),
          Pats::Categories.for('ent-eligibility-failure-6', project)
        ]
      end
    end
  end
end
