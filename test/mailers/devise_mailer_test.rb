# frozen_string_literal: true

require 'test_helper'

# Test to make sure devise emails generate correctly
class DeviseMailerTest < ActionMailer::TestCase
  test 'reset password email' do
    valid = users(:valid)

    email = Devise::Mailer.reset_password_instructions(valid, 'faketoken').deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [valid.email], email.to
    assert_equal 'Reset password instructions', email.subject
    assert_match(%r{#{ENV['website_url']}/password/edit\?reset_password_token=faketoken}, email.encoded)
  end

  test 'unlock instructions email' do
    valid = users(:valid)

    email = Devise::Mailer.unlock_instructions(valid, 'faketoken').deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [valid.email], email.to
    assert_equal 'Unlock Instructions', email.subject
    assert_match(%r{#{ENV['website_url']}/unlock\?unlock_token=faketoken}, email.encoded)
  end
end
