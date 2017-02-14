# frozen_string_literal: true

# Groups together a set of designs on a specific date.
class Event < ApplicationRecord
  # Concerns
  include Searchable, Deletable, Forkable, Sluggable, Blindable

  attr_accessor :design_hashes
  after_save :set_event_designs

  # Scopes

  # Model Validation
  validates :name, :project_id, :user_id, presence: true
  validates :name, uniqueness: { scope: [:project_id, :deleted] }
  validates :slug, uniqueness: { scope: [:project_id, :deleted] }, allow_blank: true
  validates :slug, format: { with: /\A[a-z][a-z0-9\-]*\Z/ }, allow_blank: true

  # Model Relationships
  belongs_to :user
  belongs_to :project
  has_many :event_designs, -> { order(:position) }
  has_many :designs, -> { current }, through: :event_designs

  has_many :subject_events

  # Model Methods

  def unlink_sheets_in_background!(current_user, remote_ip)
    fork_process(:unlink_sheets!, current_user, remote_ip)
  end

  def unlink_sheets!(current_user, remote_ip)
    subject_events.find_each do |subject_event|
      subject_event.unlink_sheets!(current_user, remote_ip)
    end
    subject_events.destroy_all
  end

  private

  def set_event_designs
    return unless design_hashes && design_hashes.is_a?(Array)
    event_designs.destroy_all
    design_ids = []
    design_hashes.each_with_index do |hash, index|
      next if design_ids.include? hash[:design_id].to_i
      design_ids << hash[:design_id].to_i
      design = project.designs.find_by(id: hash[:design_id])
      event_designs.create(design_id: design.id, position: index, handoff_enabled: hash[:handoff_enabled]) if design
    end
  end
end
