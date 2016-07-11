# frozen_string_literal: true

require 'pats/categories'
require 'pats/characteristics/default'
require 'pats/characteristics/age'
require 'pats/characteristics/ethnicity'
require 'pats/characteristics/gender'
require 'pats/characteristics/race'
require 'pats/characteristics/eligibility'
require 'pats/characteristics/screen_failures'
require 'pats/characteristics/not_interested_in_participation'

module Pats
  # Defines characteristic variables and associated subqueries.
  module Characteristics
    DEFAULT_CHARACTERISTIC = Pats::Characteristics::Default
    CHARACTERISTICS = {
      'age' => Pats::Characteristics::Age,
      'ethnicity' => Pats::Characteristics::Ethnicity,
      'gender' => Pats::Characteristics::Gender,
      'race' => Pats::Characteristics::Race,
      'eligibility' => Pats::Characteristics::Eligibility,
      'screen-failures' => Pats::Characteristics::ScreenFailures,
      'not-interested-in-participation' => Pats::Characteristics::NotInterestedInParticipation
    }

    def self.for(characteristic, project)
      (CHARACTERISTICS[characteristic] || DEFAULT_CHARACTERISTIC).new(project)
    end
  end
end
