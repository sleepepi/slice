# frozen_string_literal: true

# Allows adverse event emails to be viewed at /rails/mailers
class AeAdverseEventMailerPreview < ActionMailer::Preview
  def opened
    adverse_event = AeAdverseEvent.current.first
    recipient = User.current.first
    AeAdverseEventMailer.opened(adverse_event, recipient)
  end

  def sent_for_review
    adverse_event = AeAdverseEvent.current.first
    recipient = User.current.first
    AeAdverseEventMailer.sent_for_review(adverse_event, recipient)
  end
end
