# frozen_string_literal: true

require 'pats/categories/default'
require 'pats/categories/gender/female'
require 'pats/categories/gender/male'
require 'pats/categories/gender/unknown'
require 'pats/categories/race/black'
require 'pats/categories/race/other'
require 'pats/categories/race/unknown'
require 'pats/categories/age/three_to_four'
require 'pats/categories/age/five_to_six'
require 'pats/categories/age/seven_plus'
require 'pats/categories/age/unknown'
require 'pats/categories/ethnicity/hispanic'
require 'pats/categories/ethnicity/not_hispanic'
require 'pats/categories/ethnicity/unknown'
require 'pats/categories/eligibility/caregiver_not_interested'
require 'pats/categories/eligibility/fully_eligible'
require 'pats/categories/eligibility/ineligible'
require 'pats/categories/eligibility/unknown'

module Pats
  # Defines categories of variables.
  module Categories
    DEFAULT_CATEGORY = Pats::Categories::Default
    CATEGORIES = {
      'female' => Pats::Categories::Gender::Female,
      'male' => Pats::Categories::Gender::Male,
      'gender-unknown' => Pats::Categories::Gender::Unknown,
      'black-race' => Pats::Categories::Race::Black,
      'other-race' => Pats::Categories::Race::Other,
      'unknown-race' => Pats::Categories::Race::Unknown,
      'age-3to4' => Pats::Categories::Age::ThreeToFour,
      'age-5to6' => Pats::Categories::Age::FiveToSix,
      'age-7plus' => Pats::Categories::Age::SevenPlus,
      'age-unknown' => Pats::Categories::Age::Unknown,
      'hispanic' => Pats::Categories::Ethnicity::Hispanic,
      'not-hispanic' => Pats::Categories::Ethnicity::NotHispanic,
      'ethnicity-unknown' => Pats::Categories::Ethnicity::Unknown,
      'fully-eligible' => Pats::Categories::Eligibility::FullyEligible,
      'ineligible' => Pats::Categories::Eligibility::Ineligible,
      'caregiver-not-interested' => Pats::Categories::Eligibility::CaregiverNotInterested,
      'eligibility-unknown' => Pats::Categories::Eligibility::Unknown

    }

    def self.for(category, project)
      (CATEGORIES[category] || DEFAULT_CATEGORY).new(project)
    end
  end
end
