require 'test_helper'

class UserMailerTest < ActionMailer::TestCase

  test "notify system admin email" do
    valid = users(:valid)
    admin = users(:admin)

    # Send the email, then test that it got queued
    email = UserMailer.notify_system_admin(admin, valid).deliver
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [admin.email], email.to
    assert_equal "#{valid.name} Signed Up", email.subject
    assert_match(/#{valid.name} \[#{valid.email}\] has signed up for an account\./, email.encoded)
  end

  test "status activated email" do
    valid = users(:valid)

    # Send the email, then test that it got queued
    email = UserMailer.status_activated(valid).deliver
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [valid.email], email.to
    assert_equal "#{valid.name}'s Account Activated", email.subject
    assert_match(/Your account \[#{valid.email}\] has been activated\./, email.encoded)
  end

  test "sheet receipt email" do
    valid = users(:valid)

    # Send the email, then test that it got queued
    email = UserMailer.sheet_receipt(valid, 'recipient@example.com', 'cc@example.com', 'Sheet Receipt Subject', 'Body', 'sheet.pdf', '').deliver
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal ['recipient@example.com'], email.to
    assert_equal "Sheet Receipt Subject", email.subject
    assert_match(/Body/, email.encoded)
  end

  test "user invited to site email" do
    site_user = site_users(:invited)

    email = UserMailer.invite_user_to_site(site_user).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [site_user.invite_email], email.to
    assert_equal "#{site_user.creator.name} Invites You to View #{site_user.site.name}", email.subject
    assert_match(/#{site_user.creator.name} has invited you to Site #{site_user.site.name}/, email.encoded)
  end

end
