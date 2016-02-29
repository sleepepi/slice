# frozen_string_literal: true

# Allows editors and viewers to comment on sheets
class Comment < ActiveRecord::Base
  # Concerns
  include Searchable, Deletable

  after_create :create_notifications

  # Model Validation
  validates :description, :sheet_id, :user_id, presence: true

  # Model Relationships
  belongs_to :user
  belongs_to :sheet

  delegate :project, to: :sheet
  delegate :project_id, to: :sheet
  delegate :users, to: :sheet
  delegate :editable_by?, to: :sheet

  # Named Scopes

  def self.with_project(arg)
    joins(:sheet).merge(Sheet.current.where(project_id: arg))
  end

  # Model Methods

  def event_at
    created_at
  end

  def name
    "##{id}"
  end

  def number
    sheet.comments.reorder(:id).pluck(:id).index(id) + 1
  rescue
    0
  end

  def anchor
    "comment-#{number}"
  end

  def deletable_by?(current_user)
    user == current_user || editable_by?(current_user)
  end

  def self.searchable_attributes
    %w(description)
  end

  private

  def create_notifications
    users.where.not(id: user.id).each do |u|
      u.notifications.create(project_id: project_id, comment_id: id)
    end
    true
  end
end
