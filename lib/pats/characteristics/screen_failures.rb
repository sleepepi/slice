# frozen_string_literal: true

require 'pats/characteristics/default'

module Pats
  module Characteristics
    # Defines screen failures and associated categories and subqueries.
    class ScreenFailures < Default
      def label
        'Screen Failures'
      end

      def categories
        [
          Pats::Categories.for('ineligible', project),
          Pats::Categories.for('hx-psych-behavioral-disorder', project),
          Pats::Categories.for('known-cond-airway', project),
          Pats::Categories.for('ent-eligibility-not-met', project),
          Pats::Categories.for('parent-report-snoring', project),
          Pats::Categories.for('previous-osa-diagnosis', project),
          Pats::Categories.for('psg-eligibility-not-met', project),
          Pats::Categories.for('recurrent-tonsillitis', project),
          Pats::Categories.for('prev-upper-airway-surgery', project),
          Pats::Categories.for('dx-chronic-prob', project),
          Pats::Categories.for('taking-meds', project),
          Pats::Categories.for('bmi-z-score-le3', project),
          Pats::Categories.for('caregiver-understand-english', project),
          Pats::Categories.for('moving-in-year', project),
          Pats::Categories.for('foster-care', project)
        ]
      end
    end
  end
end
