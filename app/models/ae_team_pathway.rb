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
  has_many :ae_team_pathway_designs, -> { order(Arel.sql("position nulls last")) }
  has_many :designs, through: :ae_team_pathway_designs
end
