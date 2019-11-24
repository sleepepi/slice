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
    @recipient = assignment.reviewer
    @email_to = @recipient.email
    mail(to: @recipient.email,
         subject: "#{@sender.full_name} assigned you to review an adverse event on #{@adverse_event.project.name}",
         reply_to: @sender.email)
  end

  def assignment_completed(assignment, manager)
    setup_email
    @sender = assignment.reviewer
    @adverse_event = assignment.ae_adverse_event
    @recipient = manager
    @email_to = @recipient.email
    mail(to: @recipient.email,
         subject: "#{@sender.full_name} completed an adverse event review on #{@adverse_event.project.name}",
         reply_to: @sender.email)
  end

  def info_request_opened(info_request, recipient)
    setup_email
    @sender = info_request.user
    @adverse_event = info_request.ae_adverse_event
    @recipient = recipient
    @email_to = @recipient.email
    mail(to: @recipient.email,
         subject: "#{@sender.full_name} requested information for an adverse event on #{@adverse_event.project.name}",
         reply_to: @sender.email)
  end

  def info_request_resolved(info_request)
    setup_email
    @sender = info_request.resolver
    @adverse_event = info_request.ae_adverse_event
    @recipient = info_request.user
    @email_to = @recipient.email
    mail(to: @recipient.email,
         subject: "#{@sender.full_name} resolved an information request for an adverse event on #{@adverse_event.project.name}",
         reply_to: @sender.email)
  end
end
