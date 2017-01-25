# frozen_string_literal: true

require 'pats/characteristics/default'
require 'pats/characteristics/screen_failures'

module Pats
  module Characteristics
    # Defines screen failures and associated categories and subqueries for
    # constented participants.
    class ScreenFailuresConsented < ScreenFailures
      def categories
        [
          Pats::Categories.for('ent-eligibility-not-met', project),
          Pats::Categories.for('psg-eligibility-not-met', project),
          Pats::Categories.for('prev-upper-airway-surgery', project),
          Pats::Categories.for('bmi-z-score-le3', project)
        ]
      end
    end
  end
end
