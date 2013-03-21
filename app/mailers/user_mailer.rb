class UserMailer < ActionMailer::Base
  default from: "#{DEFAULT_APP_NAME} <#{ActionMailer::Base.smtp_settings[:email]}>"
  add_template_helper(ApplicationHelper)

  def notify_system_admin(system_admin, user)
    setup_email
    @system_admin = system_admin
    @user = user
    mail(to: system_admin.email,
         subject: "#{user.name} Signed Up",
         reply_to: user.email)
  end

  def status_activated(user)
    setup_email
    @user = user
    mail(to: user.email,
         subject: "#{user.name}'s Account Activated") #,
#         reply_to: user.email)
  end

  def sheet_receipt(sheet_email)
    @body = sheet_email.email_body
    filename = "#{sheet_email.sheet.subject.subject_code.strip.gsub(/[^\w]/, '-')}_#{sheet_email.sheet.name.strip.gsub(/[^\w]/, '-')}.pdf"
    attachments[filename] = { mime_type: 'application/pdf', content: sheet_email.email_pdf_file.read() } unless sheet_email.email_pdf_file.size == 0
    mail(to: sheet_email.email_to.to_s.gsub(';', ','), cc: sheet_email.email_cc.gsub(';', ','), reply_to: sheet_email.user.email, subject: sheet_email.email_subject)
  end

  def invite_user_to_site(site_user)
    setup_email
    @site_user = site_user
    mail(to: site_user.invite_email,
         subject: "#{site_user.creator.name} Invites You to View Site #{site_user.site.name}",
         reply_to: site_user.creator.email)
  end

  def user_added_to_project(project_user)
    setup_email
    @project_user = project_user
    mail(to: project_user.user.email,
         subject: "#{project_user.creator.name} Allows You to View Project #{project_user.project.name}",
         reply_to: project_user.creator.email)
  end

  def invite_user_to_project(project_user)
    setup_email
    @project_user = project_user
    mail(to: project_user.invite_email,
         subject: "#{project_user.creator.name} Invites You to View Project #{project_user.project.name}",
         reply_to: project_user.creator.email)
  end

  # Asks a user to fill in a sheet and provides a token to view and complete the sheet
  def sheet_completion_request(sheet, email)
    @sheet = sheet
    mail(to: "#{sheet.last_user.name} <#{sheet.last_user.email}>",
         bcc: email,
         subject: "Request to Fill Out #{sheet.design.name}",
         reply_to: "#{sheet.last_user.name} <#{sheet.last_user.email}>")
  end

  def survey_completed(sheet)
    @sheet = sheet
    mail(to: "#{sheet.user.name} <#{sheet.user.email}>",
         subject: "#{sheet.subject.subject_code} Submitted #{sheet.design.name}")
  end

  def export_ready(export)
    @export = export
    mail(to: "#{export.user.name} <#{export.user.email}>",
         subject: "Your Data Export for #{export.project.name} is now Ready")
  end

  def import_complete(design)
    @design = design
    mail(to: "#{design.user.name} <#{design.user.email}>",
         subject: "Your Design Data Import for #{design.project.name} is Complete")
  end

  def daily_digest(recipient)
    setup_email
    @recipient = recipient

    mail(to: recipient.email, subject: "Daily Digest for #{Date.today.strftime('%a %d %b %Y')}")
  end

  protected

  def setup_email
    @footer_html = "Change email settings here: <a href=\"#{SITE_URL}/settings\">#{SITE_URL}/settings</a>.<br /><br />".html_safe
    @footer_txt = "Change email settings here: #{SITE_URL}/settings."
  end
end
