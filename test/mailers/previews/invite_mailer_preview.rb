# frozen_string_literal: true

# Tests invite emails, viewable at /rails/mailers.
class InviteMailerPreview < ActionMailer::Preview
  def invite
    InviteMailer.invite(Invite.first)
  end
end
