# frozen_string_literal: true

# Allows emails to be viewed at /rails/mailers
class UserMailerPreview < ActionMailer::Preview
  def user_added_to_project
    project_user = ProjectUser.where.not(invite_email: nil).first
    UserMailer.user_added_to_project(project_user)
  end

  def invite_user_to_project
    project_user = ProjectUser.where.not(invite_email: nil).first
    UserMailer.invite_user_to_project(project_user)
  end

  def invite_user_to_site
    site_user = SiteUser.where.not(invite_email: nil).first
    UserMailer.invite_user_to_site(site_user)
  end

  def survey_completed
    sheet = Sheet.current.first
    UserMailer.survey_completed(sheet)
  end

  def survey_user_link
    sheet = Sheet.current.where.not(authentication_token: nil).first
    UserMailer.survey_user_link(sheet)
  end

  def export_ready
    export = Export.current.first
    UserMailer.export_ready(export)
  end

  def import_complete
    design = Design.current.first
    recipient = User.current.first
    UserMailer.import_complete(design, recipient)
  end

  # Updated
  def daily_digest
    recipient = User.current.first
    UserMailer.daily_digest(recipient)
  end

  def comment_by_mail
    comment = Comment.current.first
    recipient = User.current.first
    UserMailer.comment_by_mail(comment, recipient)
  end

  def project_news
    post = Post.current.first
    recipient = User.current.first
    UserMailer.project_news(post, recipient)
  end

  def subject_randomized
    randomization = Randomization.where.not(subject_id: nil).first
    user = User.current.first
    UserMailer.subject_randomized(randomization, user)
  end

  def adverse_event_reported
    adverse_event = AdverseEvent.current.first
    recipient = User.current.first
    UserMailer.adverse_event_reported(adverse_event, recipient)
  end

  def password_expires_soon
    recipient = User.current.first
    UserMailer.password_expires_soon(recipient)
  end
end
