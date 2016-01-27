# frozen_string_literal: true

class SiteUser < ActiveRecord::Base
  # Named Scopes
  scope :current, -> { all }

  # Model Validation
  validates :creator_id, :site_id, :project_id, presence: true
  validates :invite_token, uniqueness: true, allow_nil: true

  # Model Relationships
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'
  belongs_to :project
  belongs_to :user
  belongs_to :site

  after_create :send_invitation

  def send_invitation
    generate_invite_token!
  end

  def generate_invite_token!(new_invite_token = Digest::SHA1.hexdigest(Time.zone.now.usec.to_s))
    update(invite_token: new_invite_token) if respond_to?('invite_token') && invite_token.blank? && SiteUser.where(invite_token: new_invite_token).count == 0
    UserMailer.invite_user_to_site(self).deliver_later if EMAILS_ENABLED && !invite_token.blank?
  end
end
