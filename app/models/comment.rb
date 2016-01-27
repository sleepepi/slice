# frozen_string_literal: true

# Allows editors and viewers to comment on sheets
class Comment < ActiveRecord::Base
  # Concerns
  include Searchable, Deletable

  after_create :send_email

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

  def deletable_by?(current_user)
    user == current_user || editable_by?(current_user)
  end

  def self.searchable_attributes
    %w(description)
  end

  private

  def users_to_email
    users.where.not(id: user.id).where(emails_enabled: true)
  end

  def send_email
    return if !EMAILS_ENABLED || project.disable_all_emails?
    users_to_email.each do |user_to_email|
      UserMailer.comment_by_mail(self, user_to_email).deliver_later
    end
  end
end
