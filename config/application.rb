# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Slice
  # A clinical research interface for collecting robust and consistent data by
  # providing a framework for designing data dictionaries and collection forms.
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    # TODO: Remove this line and make :zeitwerk work with module loading dependencies.
    config.autoloader = :classic # :zeitwerk

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rails time:zones" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = "Eastern Time (US & Canada)"

    # Ignores custom error DOM elements created by Rails.
    config.action_view.field_error_proc = proc { |html_tag, _instance| html_tag }

    # Add randomization algorithms module to autoload path.
    config.autoload_paths << Rails.root.join("app", "models", "randomization_algorithm")
    config.autoload_paths << Rails.root.join("app", "models", "randomization_algorithm", "algorithms")

    # Add validation module to autoload path.
    config.autoload_paths << Rails.root.join("app", "models", "validation")
    config.autoload_paths << Rails.root.join("app", "models", "validation", "validators")

    # Add formatters module to autoload path.
    config.autoload_paths << Rails.root.join("app", "models", "formatters")

    # Add search module to autoload path.
    config.autoload_paths << Rails.root.join("app", "models", "search")

    # Add slicers module to autoload path.
    config.autoload_paths << Rails.root.join("app", "models", "slicers")

    # Add statistics module to autoload path.
    config.autoload_paths << Rails.root.join("app", "models", "statistics")

    # Add world languages module to autoload path.
    config.autoload_paths << Rails.root.join("app", "models", "world")
    config.autoload_paths << Rails.root.join("app", "models", "world", "languages")

    # Add engine module to autoload path.
    config.autoload_paths << Rails.root.join("app", "models", "engine")
    config.autoload_paths << Rails.root.join("app", "models", "engine", "expressions")
    config.autoload_paths << Rails.root.join("app", "models", "engine", "operations")
  end
end
