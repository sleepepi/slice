# frozen_string_literal: true

# Sends out application emails to users
class UserMailer < ApplicationMailer
  def survey_completed(sheet)
    setup_email
    @sheet = sheet
    @email_to = sheet.project.user.email
    mail(to: "#{sheet.project.user.full_name} <#{sheet.project.user.email}>",
         subject: "#{sheet.subject.subject_code} Submitted #{sheet.design.name}")
  end

  def sheet_unlock_request(sheet_unlock_request, editor)
    setup_email
    @sheet_unlock_request = sheet_unlock_request
    @editor = editor
    @email_to = editor.email
    mail(to: "#{editor.full_name} <#{editor.email}>",
         subject: "#{sheet_unlock_request.user.full_name} Requests To Unlock a Sheet on #{sheet_unlock_request.sheet.project.name}")
  end

  def sheet_unlocked(sheet_unlock_request, project_editor)
    setup_email
    @sheet_unlock_request = sheet_unlock_request
    @project_editor = project_editor
    @email_to = sheet_unlock_request.user.email
    mail(to: "#{sheet_unlock_request.user.full_name} <#{sheet_unlock_request.user.email}>",
         subject: "#{project_editor.full_name} Unlocked a Sheet on #{sheet_unlock_request.sheet.project.name}")
  end

  def import_complete(design, recipient)
    setup_email
    @design = design
    @recipient = recipient
    @email_to = recipient.email
    mail(to: "#{recipient.full_name} <#{recipient.email}>",
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
         subject: "#{randomization.randomized_by.full_name if randomization.randomized_by} Randomized A Subject to #{randomization.treatment_arm_name} on #{randomization.project.name}",
         reply_to: (randomization.randomized_by ? randomization.randomized_by.email : nil))
  end

  def adverse_event_reported(adverse_event, recipient)
    setup_email
    @adverse_event = adverse_event
    @recipient = recipient
    @email_to = recipient.email
    mail(to: recipient.email,
         subject: "#{adverse_event.user.full_name} Reported an Adverse Event on #{adverse_event.project.name}",
         reply_to: adverse_event.user.email)
  end

  def password_expires_soon(recipient)
    setup_email
    @recipient = recipient
    @email_to = recipient.email
    mail(to: recipient.email,
         subject: "Slice Reminder for #{recipient.full_name}")
  end
end
