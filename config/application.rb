# frozen_string_literal: true

require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
# require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in gems.rb, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Slice
  # A clinical research interface for collecting robust and consistent data by
  # providing a framework for designing data dictionaries and collection forms.
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rails time:zones" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = "Eastern Time (US & Canada)"

    # Ignores custom error DOM elements created by Rails.
    config.action_view.field_error_proc = proc { |html_tag, _instance| html_tag }

    # Add RandomizationAlgorithm Module to autoload path
    config.autoload_paths << Rails.root.join("app", "models", "randomization_algorithm")
    config.autoload_paths << Rails.root.join("app", "models", "randomization_algorithm", "algorithms")

    # Add Validation Module to autoload path
    config.autoload_paths << Rails.root.join("app", "models", "validation")
    config.autoload_paths << Rails.root.join("app", "models", "validation", "validators")

    # Add Formatters Module to autoload path
    config.autoload_paths << Rails.root.join("app", "models", "formatters")

    # Add Search Module to autoload path
    config.autoload_paths << Rails.root.join("app", "models", "search")

    # Add Slicers Module to autoload path
    config.autoload_paths << Rails.root.join("app", "models", "slicers")

    # Add Statistics Module to autoload path
    config.autoload_paths << Rails.root.join("app", "models", "statistics")
  end
end
