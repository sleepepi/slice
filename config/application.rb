# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
# require 'action_cable/engine'
require 'sprockets/railtie'
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Slice
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rails time:zones" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Eastern Time (US & Canada)'

    # Overwrite Rails errors to use Bootstrap CSS classes
    config.action_view.field_error_proc = Proc.new do |html_tag, instance|
      "<span class=\"has-error\">#{html_tag}</span>".html_safe
    end

    # Add RandomizationAlgorithm Module to autoload path
    config.autoload_paths << Rails.root.join('app', 'models', 'randomization_algorithm')
    config.autoload_paths << Rails.root.join('app', 'models', 'randomization_algorithm', 'algorithms')

    # Add Validation Module to autoload path
    config.autoload_paths << Rails.root.join('app', 'models', 'validation')
    config.autoload_paths << Rails.root.join('app', 'models', 'validation', 'validators')

    # Add Formatters Module to autoload path
    config.autoload_paths << Rails.root.join('app', 'models', 'formatters')

    # Add Search Module to autoload path
    config.autoload_paths << Rails.root.join('app', 'models', 'search')
  end
end
