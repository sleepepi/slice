# frozen_string_literal: true

# Captures discussion on an adverse event along with closing and reopening of
# the adverse event.
class AdverseEventComment < ApplicationRecord
  # Constants
  COMMENT_TYPE = %w(commented closed reopened)

  # Callbacks
  after_save :set_ae_status

  # Concerns
  include Deletable

  # Validations
  validates :project_id, :user_id, :adverse_event_id, presence: true
  validates :description, presence: true, if: :comment?
  validates :comment_type, inclusion: {
    in: COMMENT_TYPE, message: '"%{value}" is not a valid adverse event comment type'
  }

  # Relationships
  belongs_to :project
  belongs_to :user
  belongs_to :adverse_event, touch: true

  # Methods
  def number
    adverse_event.adverse_event_comments.where.not(description: ["", nil]).pluck(:id).index(id) + 1
  rescue
    0
  end

  def anchor
    "comment-#{number}"
  end

  def editable_by?(current_user)
    adverse_event.editable_by?(current_user) && current_user.all_adverse_event_comments.where(id: id).count == 1
  end

  def comment?
    comment_type == "commented"
  end

  def closed?
    comment_type == "closed"
  end

  def reopened?
    comment_type == "reopened"
  end

  def set_ae_status
    if closed?
      adverse_event.update closed: true
    elsif reopened?
      adverse_event.update closed: false
    end
  end
end
