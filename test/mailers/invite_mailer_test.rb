# frozen_string_literal: true

require "test_helper"

# Test invite emails.
class InviteMailerTest < ActionMailer::TestCase
  test "invite email" do
    invite = invites(:project_editor_unblinded)
    mail = InviteMailer.invite(invite)
    assert_equal "#{invite.inviter.full_name} invites you to join #{invite.project.name} on Slice", mail.subject
    assert_equal [invite.email], mail.to
    assert_equal ["aes_editor@example.com"], mail.reply_to
    assert_match(/#{invite.inviter.full_name} invited you to join #{invite.project.name}\./, mail.body.encoded)
  end
end
