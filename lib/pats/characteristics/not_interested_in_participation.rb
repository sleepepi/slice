# frozen_string_literal: true

require 'pats/characteristics/default'

module Pats
  module Characteristics
    # Defines not interested in participation and associated categories and subqueries.
    class NotInterestedInParticipation < Default
      def label
        'Reasons For Not Interested in Participation'
      end

      def categories
        [
          Pats::Categories.for('caregiver-not-interested', project),
          Pats::Categories.for('time-commitment-too-great', project),
          Pats::Categories.for('too-difficult-traveling-to-appointments', project),
          Pats::Categories.for('study-compensation-too-low', project),
          Pats::Categories.for('not-comfortable-with-randomization', project),
          Pats::Categories.for('unable-to-complete-screening-psg', project),
          Pats::Categories.for('unable-to-complete-ent-evaluation', project),
          Pats::Categories.for('unable-to-complete-other-testing', project),
          Pats::Categories.for('child-does-not-want-to-enroll', project),
          Pats::Categories.for('caregiver-could-not-be-contacted-for-eligibility', project),
          Pats::Categories.for('caregiver-no-showed-for-visit-and-cannot-be-contacted', project),
          Pats::Categories.for('caregiver-not-interested-other-reasons', project),
          Pats::Categories.for('disinterest-reason-unknown', project)
        ]
      end
    end
  end
end
