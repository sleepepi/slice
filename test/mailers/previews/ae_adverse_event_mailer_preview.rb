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

  def assigned_to_team
    adverse_event = AeAdverseEvent.current.joins(:ae_adverse_event_teams).first
    team = adverse_event.ae_teams.first
    sender = User.current.first
    recipient = User.current.second
    AeAdverseEventMailer.assigned_to_team(sender, adverse_event, team, recipient)
  end

  def assigned_to_reviewer
    assignment = AeAssignment.current.first
    AeAdverseEventMailer.assigned_to_reviewer(assignment)
  end
end
