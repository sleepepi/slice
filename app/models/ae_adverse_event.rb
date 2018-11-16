# frozen_string_literal: true

class AeAdverseEvent < ApplicationRecord
  # Concerns
  include Deletable
  include Squishable

  squish :description

  # Validations
  validates :description, presence: true

  # Relationships
  belongs_to :project
  belongs_to :user
  belongs_to :subject
  belongs_to :closer, class_name: "User", foreign_key: "closer_id", optional: true
  has_many :ae_adverse_event_log_entries, -> { order(:id) }
  has_many :ae_adverse_event_info_requests
  has_many :ae_adverse_event_reviewer_assignments

  # Methods
  def name
    "##{number || "???"}"
  end

  def generate_number!
    update number: adverse_event_number
  end

  def adverse_event_number
    self.class.where(project: project).order(:created_at).pluck(:id).index(id)&.send(:+, 1)
  end

  def closed?
    !closed_at.nil?
  end
end
