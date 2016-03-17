# frozen_string_literal: true

# Allows site editors to request that an auto-locked sheet be unlocked. The
# unlock request also requires the reason behind the request.
class SheetUnlockRequest < ActiveRecord::Base
  # Triggers
  after_commit :send_unlock_request_emails_in_background, on: :create

  # Concerns
  include Deletable, Forkable

  # Model Validation
  validates :user_id, :sheet_id, :reason, presence: true

  # Model Relationships
  belongs_to :user
  belongs_to :sheet

  # Model Methods
  def send_unlock_request_emails_in_background
    fork_process(:send_unlock_request_emails)
  end

  def send_unlock_request_emails
    return unless EMAILS_ENABLED
    sheet.project_editors.each do |editor|
      UserMailer.sheet_unlock_request(self, editor).deliver_later
    end
  end
end
