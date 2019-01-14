# frozen_string_literal: true

require "test_helper"

# Test to make sure devise emails generate correctly.
class DeviseMailerTest < ActionMailer::TestCase
  test "reset password email" do
    regular = users(:regular)
    email = Devise::Mailer.reset_password_instructions(regular, "faketoken").deliver_now
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [regular.email], email.to
    assert_equal "Reset password for your Slice account", email.subject
    assert_match(%r{#{ENV["website_url"]}/password/edit\?reset_password_token=faketoken}, email.encoded)
  end

  test "unlock instructions email" do
    regular = users(:regular)
    email = Devise::Mailer.unlock_instructions(regular, "faketoken").deliver_now
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [regular.email], email.to
    assert_equal "Unlock your Slice account", email.subject
    assert_match(%r{#{ENV["website_url"]}/unlock\?unlock_token=faketoken}, email.encoded)
  end
end
