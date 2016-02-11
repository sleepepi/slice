# frozen_string_literal: true

# Sends out application emails to users
class UserMailer < ApplicationMailer
  def invite_user_to_site(site_user)
    setup_email
    @site_user = site_user
    @email_to = site_user.invite_email
    mail(to: site_user.invite_email,
         subject: "#{site_user.creator.name} Invites You to View Site #{site_user.site.name}",
         reply_to: site_user.creator.email)
  end

  def user_added_to_project(project_user)
    setup_email
    @project_user = project_user
    @email_to = project_user.user.email
    mail(to: project_user.user.email,
         subject: "#{project_user.creator.name} Allows You to #{project_user.editor? ? 'Edit' : 'View'} Project #{project_user.project.name}",
         reply_to: project_user.creator.email)
  end

  def invite_user_to_project(project_user)
    setup_email
    @project_user = project_user
    @email_to = project_user.invite_email
    mail(to: project_user.invite_email,
         subject: "#{project_user.creator.name} Invites You to #{project_user.editor? ? 'Edit' : 'View'} Project #{project_user.project.name}",
         reply_to: project_user.creator.email)
  end

  def survey_completed(sheet)
    @sheet = sheet
    @email_to = sheet.project.user.email
    mail(to: "#{sheet.project.user.name} <#{sheet.project.user.email}>",
         subject: "#{sheet.subject.subject_code} Submitted #{sheet.design.name}")
  end

  def survey_user_link(sheet)
    @sheet = sheet
    @email_to = sheet.subject.email
    mail(to: sheet.subject.email,
         subject: "Thank you for Submitting #{sheet.design.name}")
  end

  def export_ready(export)
    @export = export
    @email_to = export.user.email
    mail(to: "#{export.user.name} <#{export.user.email}>",
         subject: "Your Data Export for #{export.project.name} is now Ready")
  end

  def import_complete(design, recipient)
    @design = design
    @recipient = recipient
    @email_to = recipient.email
    mail(to: "#{recipient.name} <#{recipient.email}>",
         subject: "Your Design Data Import for #{design.project.name} is Complete")
  end

  def daily_digest(recipient)
    setup_email
    @recipient = recipient
    @email_to = recipient.email

    mail(to: recipient.email, subject: "Daily Digest for #{Date.today.strftime('%a %d %b %Y')}")
  end

  def project_news(post, recipient)
    @post = post
    @recipient = recipient
    @email_to = recipient.email
    mail(to: recipient.email,
         subject: "#{post.name} [#{post.user.name} Added a News Post on #{post.project.name}]",
         reply_to: post.user.email)
  end

  def subject_randomized(randomization, user)
    setup_email
    @randomization = randomization
    @user = user
    @email_to = user.email
    mail(to: user.email,
         subject: "#{randomization.randomized_by.name if randomization.randomized_by} Randomized A Subject to #{randomization.treatment_arm.name} on #{randomization.project.name}",
         reply_to: (randomization.randomized_by ? randomization.randomized_by.email : nil))
  end

  def adverse_event_reported(adverse_event, recipient)
    setup_email
    @adverse_event = adverse_event
    @recipient = recipient
    @email_to = recipient.email
    mail(to: recipient.email,
         subject: "#{adverse_event.user.name} Reported an Adverse Event on #{adverse_event.project.name}",
         reply_to: adverse_event.user.email)
  end

  def password_expires_soon(recipient)
    setup_email
    @recipient = recipient
    @email_to = recipient.email
    mail(to: recipient.email,
         subject: 'Your password will expire soon')
  end
end
