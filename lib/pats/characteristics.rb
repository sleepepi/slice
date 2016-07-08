# frozen_string_literal: true

require 'pats/categories'
require 'pats/characteristics/default'
require 'pats/characteristics/age'
require 'pats/characteristics/ethnicity'
require 'pats/characteristics/gender'
require 'pats/characteristics/race'
require 'pats/characteristics/eligibility'

module Pats
  # Defines characteristic variables and associated subqueries.
  module Characteristics
    DEFAULT_CHARACTERISTIC = Pats::Characteristics::Default
    CHARACTERISTICS = {
      'age' => Pats::Characteristics::Age,
      'ethnicity' => Pats::Characteristics::Ethnicity,
      'gender' => Pats::Characteristics::Gender,
      'race' => Pats::Characteristics::Race,
      'eligibility' => Pats::Characteristics::Eligibility
    }

    def self.for(characteristic, project)
      (CHARACTERISTICS[characteristic] || DEFAULT_CHARACTERISTIC).new(project)
    end
  end
end
