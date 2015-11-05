class Post < ActiveRecord::Base
  after_create :send_email

  # Concerns
  include Searchable, Deletable

  # Named Scopes

  # Model Validation
  validates :name, :description, :project_id, :user_id, presence: true

  # Model Relationships
  belongs_to :user
  belongs_to :project

  # Model Methods

  private

  def send_email
    return if archived?
    all_users = project.users_to_email - [user]
    all_users.each do |user_to_email|
      UserMailer.project_news(self, user_to_email).deliver_later if EMAILS_ENABLED
    end
  end
end
