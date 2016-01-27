# frozen_string_literal: true

# Use to configure basic appearance of template
Contour.setup do |config|
  # Enter your application name here. The name will be displayed in the title of
  # all pages, ex: AppName - PageTitle
  config.application_name = ENV['website_name']

  # Enter your application version here. Do not include a trailing backslash.
  # Recommend using a predefined constant
  config.application_version = Slice::VERSION::STRING

  # An array of hashes that specify additional fields to add to the sign up form
  # An example might be [ { attribute: 'first_name', type: 'text_field' },
  #                       { attribute: 'last_name', type: 'text_field' } ]
  config.sign_up_fields = [{ attribute: 'first_name', type: 'text_field' },
                           { attribute: 'last_name', type: 'text_field' },
                           { attribute: 'emails_enabled', type: 'check_box' }]

  # An array of text fields used to trick spam bots using the honeypot approach.
  # These text fields will not be displayed to the user.
  # An example might be [ :url, :address, :contact, :comment ]
  config.spam_fields = [:url, :address, :contact, :comment]
end
