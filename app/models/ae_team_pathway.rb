# frozen_string_literal: true

class AeTeamPathway < ApplicationRecord
  # Concerns
  include Deletable

  # Validations
  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false, scope: :ae_review_team_id }
  validates :number_of_reviewers, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  # Relationships
  belongs_to :project
  belongs_to :ae_review_team

  has_many :ae_designments, -> { order(Arel.sql("position nulls last")) }
  has_many :designs, through: :ae_designments

  # Methods

  def first_design
    designs.first
  end

  def next_design(design)
    design_array = designs.to_a
    number = design_array.collect(&:id).index(design.id)
    design_array[number + 1] if number
  end
end
