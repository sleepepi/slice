# frozen_string_literal: true

require "test_helper"

# Tests for adverse event emails.
class AeAdverseEventMailerTest < ActionMailer::TestCase
  test "opened" do
    adverse_event = ae_adverse_events(:reported)
    review_admin = users(:aes_review_admin)
    mail = AeAdverseEventMailer.opened(adverse_event, review_admin)
    assert_equal [review_admin.email], mail.to
    assert_equal(
      "#{adverse_event.user.full_name} opened an adverse event on #{adverse_event.project.name}",
      mail.subject
    )
    assert_match(
      %r{#{adverse_event.user.full_name} opened an adverse event on #{adverse_event.project.name} located here: #{ENV["website_url"]}/projects/#{adverse_event.project.to_param}},
      mail.body.encoded
    )
  end

  test "sent for review" do
    adverse_event = ae_adverse_events(:reported)
    review_admin = users(:aes_review_admin)
    mail = AeAdverseEventMailer.sent_for_review(adverse_event, review_admin)
    assert_equal [review_admin.email], mail.to
    assert_equal(
      "#{adverse_event.user.full_name} sent an adverse event for review on #{adverse_event.project.name}",
      mail.subject
    )
    assert_match(
      %r{#{adverse_event.user.full_name} sent an adverse event for review on #{adverse_event.project.name} located here: #{ENV["website_url"]}/projects/#{adverse_event.project.to_param}},
      mail.body.encoded
    )
  end

  test "assigned to team" do
    adverse_event = ae_adverse_events(:teamset)
    review_admin = users(:aes_review_admin)
    team = ae_teams(:clinical)
    team_manager = users(:aes_team_manager)
    mail = AeAdverseEventMailer.assigned_to_team(review_admin, adverse_event, team, team_manager)
    assert_equal [team_manager.email], mail.to
    assert_equal(
      "#{review_admin.full_name} assigned an adverse event to #{team.name} on #{adverse_event.project.name}",
      mail.subject
    )
    assert_match(
      %r{#{review_admin.full_name} assigned an adverse event to #{team.name} on #{adverse_event.project.name} located here: #{ENV["website_url"]}/projects/#{adverse_event.project.to_param}},
      mail.body.encoded
    )
  end
end
