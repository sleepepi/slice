# frozen_string_literal: true

require 'pats/characteristics/default'
require 'pats/characteristics/eligibility'

module Pats
  module Characteristics
    # Defines eligibility and associated categories and subqueries for
    # constented participants.
    class EligibilityConsented < Eligibility
      def categories
        [
          Pats::Categories.for('fully-eligible', project),
          Pats::Categories.for('ineligible', project),
          Pats::Categories.for('eligibility-unknown', project)
        ]
      end
    end
  end
end
