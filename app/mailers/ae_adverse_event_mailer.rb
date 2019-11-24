# frozen_string_literal: true

# Send emails when adverse events are opened and sent for review.
class AeAdverseEventMailer < ApplicationMailer
  def opened(adverse_event, recipient)
    setup_email
    @adverse_event = adverse_event
    @sender = adverse_event.user
    @recipient = recipient
    @email_to = @recipient.email
    mail(to: @recipient.email,
         subject: "#{@sender.full_name} opened an adverse event on #{@adverse_event.project.name}",
         reply_to: @sender.email)
  end

  def sent_for_review(adverse_event, recipient)
    setup_email
    @adverse_event = adverse_event
    @sender = adverse_event.user
    @recipient = recipient
    @email_to = @recipient.email
    mail(to: @recipient.email,
         subject: "#{@sender.full_name} sent an adverse event for review on #{@adverse_event.project.name}",
         reply_to: @sender.email)
  end

  def assigned_to_team(sender, adverse_event, team, recipient)
    setup_email
    @sender = sender
    @adverse_event = adverse_event
    @team = team
    @recipient = recipient
    @email_to = @recipient.email
    mail(to: @recipient.email,
         subject: "#{@sender.full_name} assigned an adverse event to #{team.name} on #{@adverse_event.project.name}",
         reply_to: @sender.email)
  end

  def assigned_to_reviewer(assignment)
    setup_email
    @sender = assignment.manager
    @adverse_event = assignment.ae_adverse_event
    @team = assignment.ae_team
    @recipient = assignment.reviewer
    @email_to = @recipient.email
    mail(to: @recipient.email,
         subject: "#{@sender.full_name} assigned you to review an adverse event on #{@adverse_event.project.name}",
         reply_to: @sender.email)
  end
end
