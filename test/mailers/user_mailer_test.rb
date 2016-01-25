require 'test_helper'

# Tests that mail views are rendered corretly, sent to correct user, and have a
# correct subject line
class UserMailerTest < ActionMailer::TestCase
  test 'user invited to site email' do
    site_user = site_users(:invited)

    email = UserMailer.invite_user_to_site(site_user).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [site_user.invite_email], email.to
    assert_equal "#{site_user.creator.name} Invites You to View Site #{site_user.site.name}", email.subject
    assert_match(/#{site_user.creator.name} invited you to Site #{site_user.site.name}/, email.encoded)
  end

  test 'user added to project email' do
    project_user = project_users(:accepted_viewer_invite)

    email = UserMailer.user_added_to_project(project_user).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [project_user.user.email], email.to
    assert_equal "#{project_user.creator.name} Allows You to View Project #{project_user.project.name}", email.subject
    assert_match(/#{project_user.creator.name} added you to Project #{project_user.project.name}/, email.encoded)
  end

  test 'user invited to project email' do
    project_user = project_users(:pending_editor_invite)

    email = UserMailer.invite_user_to_project(project_user).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [project_user.invite_email], email.to
    assert_equal "#{project_user.creator.name} Invites You to Edit Project #{project_user.project.name}", email.subject
    assert_match(/#{project_user.creator.name} invited you to Project #{project_user.project.name}/, email.encoded)
  end

  test 'survey completed email' do
    sheet = sheets(:external)

    email = UserMailer.survey_completed(sheet).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [sheet.project.user.email], email.to
    assert_equal "#{sheet.subject.subject_code} Submitted #{sheet.design.name}", email.subject
    assert_match(/#{sheet.subject.subject_code} completed a survey that you requested for #{sheet.name}\. You can view the completed sheet here:/, email.encoded)
  end

  test 'survey user link' do
    sheet = sheets(:external_with_email)

    email = UserMailer.survey_user_link(sheet).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [sheet.subject.email], email.to
    assert_equal "Thank you for Submitting #{sheet.design.name}", email.subject
    assert_match(/Thank you for submitting #{sheet.name}\.\r\n\r\nYou can make changes to your survey responses here:/, email.encoded)
  end

  test 'export ready email' do
    export = exports(:one)

    email = UserMailer.export_ready(export).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [export.user.email], email.to
    assert_equal "Your Data Export for #{export.project.name} is now Ready", email.subject
    assert_match(/The data export you requested for #{export.project.name} is now ready for download\./, email.encoded)
  end

  test 'import complete email' do
    design = designs(:one)
    valid = users(:valid)

    email = UserMailer.import_complete(design, valid).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [valid.email], email.to
    assert_equal "Your Design Data Import for #{design.project.name} is Complete", email.subject
    assert_match(/The design data import for #{design.project.name} is now complete\./, email.encoded)
  end

  test 'daily digest email' do
    valid = users(:valid)

    email = UserMailer.daily_digest(valid).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [valid.email], email.to
    assert_equal "Daily Digest for #{Date.today.strftime('%a %d %b %Y')}", email.subject
    assert_match(/Dear #{valid.first_name},/, email.encoded)
  end

  test 'comment by mail email' do
    comment = comments(:one)
    valid = users(:valid)

    email = UserMailer.comment_by_mail(comment, valid).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [valid.email], email.to
    assert_equal "#{comment.user.name} Commented on #{comment.sheet.name} on #{comment.sheet.project.name}", email.subject
    assert_match(%r{#{comment.user.name} COMMENTED on #{comment.sheet.name} on #{comment.sheet.project.name} located at #{ENV['website_url']}/projects/#{comment.sheet.project.to_param}/sheets/#{comment.sheet.id}\.}, email.encoded)
  end

  test 'project news post email' do
    post = posts(:one)
    valid = users(:valid)

    email = UserMailer.project_news(post, valid).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [valid.email], email.to
    assert_equal "#{post.name} [#{post.user.name} Added a News Post on #{post.project.name}]", email.subject
    assert_match(/This post was added by #{post.user.name} to #{post.project.name} on #{ENV['website_name']}/, email.encoded)
  end

  test 'subject randomization' do
    randomization = randomizations(:one)
    user = users(:valid)

    email = UserMailer.subject_randomized(randomization, user).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [user.email], email.to
    assert_equal "#{randomization.user.name} Randomized A Subject to #{randomization.treatment_arm.name} on #{randomization.project.name}", email.subject
    assert_match(/#{randomization.subject.name} was randomized to #{randomization.treatment_arm.name} on #{randomization.project.name} by #{randomization.user.name}\./, email.encoded)
  end

  test 'adverse event reported email' do
    adverse_event = adverse_events(:one)
    valid = users(:valid)

    email = UserMailer.adverse_event_reported(adverse_event, valid).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [valid.email], email.to
    assert_equal "#{adverse_event.user.name} Reported an Adverse Event on #{adverse_event.project.name}", email.subject
    assert_match(%r{#{adverse_event.user.name} reported an adverse event on #{adverse_event.project.name} located here: #{ENV['website_url']}/projects/#{adverse_event.project.to_param}}, email.encoded)
  end

  test 'password expires soon email' do
    valid = users(:valid)

    email = UserMailer.password_expires_soon(valid).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [valid.email], email.to
    assert_equal 'Your password will expire soon', email.subject
    assert_match(/Your #{ENV['website_name']} password will expire in [\d]+ day[s]? on #{valid.password_expires_on.strftime('%-m-%-d-%Y.')} Click the link below to reset your password now:/, email.encoded)
  end
end
