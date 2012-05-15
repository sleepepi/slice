class UserMailer < ActionMailer::Base
  default from: ActionMailer::Base.smtp_settings[:user_name]
  add_template_helper(ApplicationHelper)

  def notify_system_admin(system_admin, user)
    setup_email
    @system_admin = system_admin
    @user = user
    mail(to: system_admin.email,
         subject: @subject + "#{user.name} Signed Up",
         reply_to: user.email)
  end

  def status_activated(user)
    setup_email
    @user = user
    mail(to: user.email,
         subject: @subject + "#{user.name}'s Account Activated") #,
#         reply_to: user.email)
  end

  protected

  def setup_email
    @subject = "[#{DEFAULT_APP_NAME}#{'-development' if Rails.env == 'development'}] "
    @footer_html = "Change email settings here: <a href=\"#{SITE_URL}/settings\">#{SITE_URL}/settings</a>.<br /><br />".html_safe
    @footer_txt = "Change email settings here: #{SITE_URL}/settings."
  end
end
