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
          Pats::Categories.for('caregiver-not-interested', project)
        ]
      end
    end
  end
end
