class Comment < ActiveRecord::Base
  # Concerns
  include Searchable, Deletable

  # Named Scopes
  scope :with_project, -> (arg) { where('comments.sheet_id in (select sheets.id from sheets where sheets.deleted = ? and sheets.project_id IN (?))', false, arg) }

  after_create :send_email

  # Model Validation
  validates :description, :sheet_id, :user_id, presence: true

  # Model Relationships
  belongs_to :user
  belongs_to :sheet

  delegate :project_id, to: :sheet

  def event_at
    created_at
  end

  def name
    "##{id}"
  end

  def users_to_email
    (notifiable_users - [user]).select { |u| email_user?(u) }
  end

  def editable_by?(current_user)
    sheet.project.editable_by?(current_user)
  end

  def deletable_by?(current_user)
    user == current_user || editable_by?(current_user)
  end

  def self.searchable_attributes
    %w(description)
  end

  private

  def email_user?(u)
    u.emails_enabled? && u.email_on?(:sheet_comment) && u.email_on?("project_#{sheet.project.id}_sheet_comment")
  end

  def notifiable_users
    (sheet.project.users + [sheet.project.user] + sheet.subject.site.users).uniq
  end

  def send_email
    users_to_email.each do |user_to_email|
      UserMailer.comment_by_mail(self, user_to_email).deliver_later if Rails.env.production? && !sheet.project.disable_all_emails?
    end
  end
end
