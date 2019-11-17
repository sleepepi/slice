# frozen_string_literal: true

# Send emails when adverse events are opened and sent for review.
class AeAdverseEventMailer < ApplicationMailer
  def opened(adverse_event, recipient)
    setup_email
    @adverse_event = adverse_event
    @recipient = recipient
    @email_to = recipient.email
    mail(to: recipient.email,
         subject: "#{adverse_event.user.full_name} opened an adverse event on #{adverse_event.project.name}",
         reply_to: adverse_event.user.email)
  end

  def sent_for_review(adverse_event, recipient)
    setup_email
    @adverse_event = adverse_event
    @recipient = recipient
    @email_to = recipient.email
    mail(to: recipient.email,
         subject: "#{adverse_event.user.full_name} sent an adverse event for review on #{adverse_event.project.name}",
         reply_to: adverse_event.user.email)
  end
end
