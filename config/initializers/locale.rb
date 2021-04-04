# frozen_string_literal: true

# # Where the I18n library should search for translation files.
# NOTE: The following line doesn't work since it reincludes devise.en.yml,
# which causes devise to display default devise messages. Instead each subfolder
# has to be individually included to changing the order in which devise.en.yml
# is read.
# I18n.load_path += Dir[Rails.root.join("config", "locales", "**", "*.{rb,yml}")] # DO NOT USE
I18n.load_path += Dir[Rails.root.join("config", "locales", "handoffs", "*.{rb,yml}")]
I18n.load_path += Dir[Rails.root.join("config", "locales", "latex", "*.{rb,yml}")]
I18n.load_path += Dir[Rails.root.join("config", "locales", "sheets", "*.{rb,yml}")]
I18n.load_path += Dir[Rails.root.join("config", "locales", "validators", "*.{rb,yml}")]

# Available locales for the application.
I18n.available_locales = [:en, :es, :"fr-CA"]

# Set default locale to something other than :en.
# I18n.default_locale = :en
