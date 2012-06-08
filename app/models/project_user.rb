class ProjectUser < ActiveRecord::Base
  attr_accessible :librarian, :project_id, :user_id

  belongs_to :project
  belongs_to :user

  # after_update :notify_user

  # private

  # def notify_user
  #   UserMailer.user_added_to_project(self).deliver if Rails.env.production?
  # end
end
