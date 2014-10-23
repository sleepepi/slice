class Post < ActiveRecord::Base

  after_create :send_email

  # Concerns
  include Searchable, Deletable

  # Named Scopes

  # Model Validation
  validates_presence_of :name, :description, :project_id, :user_id

  # Model Relationships
  belongs_to :user
  belongs_to :project

  # Model Methods

  private

    def send_email
      unless self.archived?
        all_users = self.project.users_to_email - [self.user]
        all_users.each do |user_to_email|
          UserMailer.project_news(self, user_to_email).deliver_later if Rails.env.production?
        end
      end
    end

end
