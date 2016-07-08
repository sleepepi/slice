# frozen_string_literal: true

require 'pats/categories/default'
require 'pats/categories/gender/female'
require 'pats/categories/gender/male'
require 'pats/categories/race/black'
require 'pats/categories/race/other'
require 'pats/categories/age/three_to_four'
require 'pats/categories/age/five_to_six'
require 'pats/categories/age/seven_plus'


module Pats
  # Defines categories of variables.
  module Categories
    DEFAULT_CATEGORY = Pats::Categories::Default
    CATEGORIES = {
      'female' => Pats::Categories::Gender::Female,
      'male' => Pats::Categories::Gender::Male,
      'black-race' => Pats::Categories::Race::Black,
      'other-race' => Pats::Categories::Race::Other,
      'age-3to4' => Pats::Categories::Age::ThreeToFour,
      'age-5to6' => Pats::Categories::Age::FiveToSix,
      'age-7plus' => Pats::Categories::Age::SevenPlus
    }

    def self.for(category, project)
      (CATEGORIES[category] || DEFAULT_CATEGORY).new(project)
    end
  end
end
