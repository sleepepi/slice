# frozen_string_literal: true

# Sends generic invite email to users.
class InviteMailer < ApplicationMailer
  def invite(invite)
    setup_email
    @invite = invite
    @email_to = invite.email
    mail(
      to: @email_to,
      subject: "#{invite.inviter.full_name} invites you to join #{invite.project.name} on Slice",
      reply_to: invite.inviter.email
    )
  end
end
