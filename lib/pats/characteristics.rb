# frozen_string_literal: true

require 'pats/categories'
require 'pats/characteristics/default'
require 'pats/characteristics/age'
require 'pats/characteristics/ethnicity'
require 'pats/characteristics/gender'
require 'pats/characteristics/race'
require 'pats/characteristics/eligibility'
require 'pats/characteristics/eligibility_consented'
require 'pats/characteristics/screen_failures'
require 'pats/characteristics/screen_failures_consented'
require 'pats/characteristics/not_interested_in_participation'
require 'pats/characteristics/ent_failures'
require 'pats/characteristics/psg_failures'
require 'pats/characteristics/psg_overall_study_quality'
require 'pats/characteristics/psg_study_passed'

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
      'eligibility-consented' => Pats::Characteristics::EligibilityConsented,
      'screen-failures' => Pats::Characteristics::ScreenFailures,
      'screen-failures-consented' => Pats::Characteristics::ScreenFailuresConsented,
      'not-interested-in-participation' => Pats::Characteristics::NotInterestedInParticipation,
      'ent-failures' => Pats::Characteristics::ENTFailures,
      'psg-failures' => Pats::Characteristics::PSGFailures,
      'psg-overall-study-quality' => Pats::Characteristics::PSGOverallStudyQuality,
      'psg-study-passed' => Pats::Characteristics::PSGStudyPassed
    }

    def self.for(characteristic, project)
      (CHARACTERISTICS[characteristic] || DEFAULT_CHARACTERISTIC).new(project)
    end
  end
end
