# frozen_string_literal: true

class Event < ActiveRecord::Base
  # Concerns
  include Searchable, Deletable

  attr_accessor :design_hashes
  after_save :set_event_designs

  # Named Scopes

  # Model Validation
  validates :name, :project_id, :user_id, presence: true
  validates :name, uniqueness: { scope: [:project_id, :deleted] }
  validates :slug, uniqueness: { scope: [:project_id, :deleted] }, allow_blank: true
  validates :slug, format: { with: /\A[a-z][a-z0-9\-]*\Z/ }, allow_blank: true

  # Model Relationships
  belongs_to :user
  belongs_to :project
  has_many :event_designs, -> { order(:position) }
  has_many :designs, -> { where deleted: false }, through: :event_designs

  has_many :subject_events

  # Model Methods

  def to_param
    slug.blank? ? id : slug
  end

  def self.find_by_param(input)
    find_by 'events.slug = ? or events.id = ?', input.to_s, input.to_i
  end

  private

  def set_event_designs
    return unless design_hashes && design_hashes.is_a?(Array)
    event_designs.destroy_all
    design_ids = []
    design_hashes.each_with_index do |hash, index|
      next if design_ids.include? hash[:design_id].to_i
      design_ids << hash[:design_id].to_i
      design = project.designs.find_by_id hash[:design_id]
      event_designs.create(design_id: design.id, position: index, handoff_enabled: hash[:handoff_enabled]) if design
    end
  end
end
