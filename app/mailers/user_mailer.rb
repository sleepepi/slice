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
    setup_email
    @sheet = sheet
    @email_to = sheet.project.user.email
    mail(to: "#{sheet.project.user.name} <#{sheet.project.user.email}>",
         subject: "#{sheet.subject.subject_code} Submitted #{sheet.design.name}")
  end

  def sheet_unlock_request(sheet_unlock_request, editor)
    setup_email
    @sheet_unlock_request = sheet_unlock_request
    @editor = editor
    @email_to = editor.email
    mail(to: "#{editor.name} <#{editor.email}>",
         subject: "#{sheet_unlock_request.user.name} Requests To Unlock a Sheet on Project #{sheet_unlock_request.sheet.project.name}")
  end

  def sheet_unlocked(sheet_unlock_request, project_editor)
    setup_email
    @sheet_unlock_request = sheet_unlock_request
    @project_editor = project_editor
    @email_to = sheet_unlock_request.user.email
    mail(to: "#{sheet_unlock_request.user.name} <#{sheet_unlock_request.user.email}>",
         subject: "#{project_editor.name} Unlocked a Sheet on Project #{sheet_unlock_request.sheet.project.name}")
  end

  def survey_user_link(sheet)
    setup_email
    @sheet = sheet
    @email_to = sheet.subject.email
    mail(to: sheet.subject.email,
         subject: "Thank you for Submitting #{sheet.design.name}")
  end

  def export_ready(export)
    setup_email
    @export = export
    @email_to = export.user.email
    mail(to: "#{export.user.name} <#{export.user.email}>",
         subject: "Your Data Export for #{export.project.name} is now Ready")
  end

  def import_complete(design, recipient)
    setup_email
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
    @digest_sheets = @recipient.digest_sheets_created
    @digest_comments = @recipient.digest_comments
    mail(to: recipient.email, subject: "Daily Digest for #{Time.zone.today.strftime('%a %d %b %Y')}")
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
         subject: "Slice Reminder for #{recipient.name}")
  end
end
