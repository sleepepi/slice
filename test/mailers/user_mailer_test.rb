# frozen_string_literal: true

require "test_helper"

# Tests that mail views are rendered correctly, sent to correct user, and have a
# correct subject line
class UserMailerTest < ActionMailer::TestCase
  test "survey completed email" do
    sheet = sheets(:external)
    mail = UserMailer.survey_completed(sheet)
    assert_equal [sheet.project.user.email], mail.to
    assert_equal "#{sheet.subject.subject_code} Submitted #{sheet.design.name}", mail.subject
    assert_match(/#{sheet.subject.subject_code} completed a survey that you requested for #{sheet.name}\. You can view the completed sheet here:/, mail.body.encoded)
  end

  test "sheet unlock request email" do
    sheet_unlock_request = sheet_unlock_requests(:one)
    editor = users(:regular)
    mail = UserMailer.sheet_unlock_request(sheet_unlock_request, editor)
    assert_equal [editor.email], mail.to
    assert_equal "#{sheet_unlock_request.user.full_name} Requests To Unlock a Sheet on #{sheet_unlock_request.sheet.project.name}", mail.subject
    assert_match(/#{sheet_unlock_request.user.full_name} has requested that the following sheet be unlocked on #{sheet_unlock_request.sheet.project.name}\. You can review the request here:/, mail.body.encoded)
  end

  test "sheet unlocked email" do
    sheet_unlock_request = sheet_unlock_requests(:one)
    project_editor = users(:regular)
    mail = UserMailer.sheet_unlocked(sheet_unlock_request, project_editor)
    assert_equal [sheet_unlock_request.user.email], mail.to
    assert_equal "#{project_editor.full_name} Unlocked a Sheet on #{sheet_unlock_request.sheet.project.name}", mail.subject
    assert_match(/#{project_editor.full_name} has unlocked a sheet for 24 hours on #{sheet_unlock_request.sheet.project.name}\. You can now edit the sheet here:/, mail.body.encoded)
  end

  test "daily digest email" do
    regular = users(:regular)
    mail = UserMailer.daily_digest(regular)
    assert_equal [regular.email], mail.to
    assert_equal "Daily Digest for #{Time.zone.today.strftime("%a %d %b %Y")}", mail.subject
    assert_match(/Dear #{regular.full_name},/, mail.body.encoded)
  end

  test "subject randomization" do
    randomization = randomizations(:one)
    user = users(:regular)
    mail = UserMailer.subject_randomized(randomization, user)
    assert_equal [user.email], mail.to
    assert_equal "#{randomization.user.full_name} Randomized A Subject to #{randomization.treatment_arm_name} on #{randomization.project.name}", mail.subject
    assert_match(/#{randomization.subject.name} was randomized to #{randomization.treatment_arm_name} on #{randomization.project.name} by #{randomization.user.full_name}\./, mail.body.encoded)
  end

  test "adverse event reported email" do
    adverse_event = adverse_events(:one)
    regular = users(:regular)
    mail = UserMailer.adverse_event_reported(adverse_event, regular)
    assert_equal [regular.email], mail.to
    assert_equal "#{adverse_event.user.full_name} Reported an Adverse Event on #{adverse_event.project.name}", mail.subject
    assert_match(%r{#{adverse_event.user.full_name} reported an adverse event on #{adverse_event.project.name} located here: #{ENV["website_url"]}/projects/#{adverse_event.project.to_param}}, mail.body.encoded)
  end

  test "password expires soon email" do
    regular = users(:regular)
    mail = UserMailer.password_expires_soon(regular)
    assert_equal [regular.email], mail.to
    assert_equal "Slice Reminder for #{regular.full_name}", mail.subject
    assert_match(/Your #{ENV["website_name"]} password will expire in [\d]+ day[s]? on #{regular.password_expires_on.strftime("%-m-%-d-%Y.")}/, mail.body.encoded)
  end
end
