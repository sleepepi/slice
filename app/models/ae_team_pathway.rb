# frozen_string_literal: true

class AeTeamPathway < ApplicationRecord
  # Constants
  ORDERS = {
    "name desc" => "ae_team_pathways.name desc",
    "name" => "ae_team_pathways.name"
  }
  DEFAULT_ORDER = "ae_team_pathways.name"

  # Concerns
  include Deletable
  include Searchable

  # Validations
  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false, scope: :ae_team_id }

  # Relationships
  belongs_to :project
  belongs_to :ae_team, counter_cache: :pathways_count

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

  def destroy
    super
    AeTeam.reset_counters(ae_team.id, :ae_team_pathways)
  end

  def self.searchable_attributes
    %w(name)
  end
end
