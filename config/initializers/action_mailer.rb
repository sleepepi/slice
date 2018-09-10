# frozen_string_literal: true

ActionMailer::Base.default_url_options[:host] = ENV["website_url"].to_s.gsub(%r{^https?://}, "")
if Rails.env.test?
  ActionMailer::Base.delivery_method = :test
  ActionMailer::Base.smtp_settings[:email] = "travis-ci@example.com"
  EMAILS_ENABLED = true
else
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    address: Rails.application.credentials.dig(:smtp_address),
    port: Rails.application.credentials.dig(:smtp_port).to_i,
    authentication: Rails.application.credentials.dig(:smtp_authentication).to_sym, # :plain, :login, or, :cram_md5
    email: Rails.application.credentials.dig(:smtp_email),
    user_name: Rails.application.credentials.dig(:smtp_user_name),
    password: Rails.application.credentials.dig(:smtp_password)
  }
  EMAILS_ENABLED = (ENV["emails_enabled"] == "true")
end
