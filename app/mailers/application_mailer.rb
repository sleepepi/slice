# frozen_string_literal: true

# Generic mailer class defines layout and email sender.
class ApplicationMailer < ActionMailer::Base
  default from: "#{ENV["website_name"]} <#{ActionMailer::Base.smtp_settings[:email]}>"
  add_template_helper(ApplicationHelper) # For `simple_markdown`
  add_template_helper(EmailHelper)
  layout "mailer"

  protected

  def setup_email
    location = "app/assets/images/logos/slice-v5-transparent-logo.png"
    attachments.inline["slice-logo.png"] = File.read(location)
  rescue
    nil
  end
end
