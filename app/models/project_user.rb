# Provides methods to invite a new member to an existing project
class ProjectUser < ActiveRecord::Base
  # Model Validation
  validates :project_id, :creator_id, presence: true
  validates :invite_token, uniqueness: true, allow_nil: true

  # Model Relationships
  belongs_to :project
  belongs_to :user
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'

  after_update :notify_user

  def generate_invite_token!(new_invite_token = generate_token)
    save_invite_token new_invite_token
    send_invite_token
  end

  private

  def save_invite_token(new_invite_token)
    update invite_token: new_invite_token if respond_to?('invite_token') && invite_token.blank? && ProjectUser.where(invite_token: new_invite_token).count == 0
  end

  def send_invite_token
    UserMailer.invite_user_to_project(self).deliver_later if EMAILS_ENABLED && !invite_token.blank?
  end

  def notify_user
    UserMailer.user_added_to_project(self).deliver_later if EMAILS_ENABLED && invite_token.blank? && user
  end

  def generate_token
    Digest::SHA1.hexdigest(Time.zone.now.usec.to_s)
  end
end
