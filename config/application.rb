# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

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

    # Add RandomizationAlgorithm Module to autoload path
    config.autoload_paths << Rails.root.join('app', 'models', 'randomization_algorithm')
    config.autoload_paths << Rails.root.join('app', 'models', 'randomization_algorithm', 'algorithms')

    # Add Validation Module to autoload path
    config.autoload_paths << Rails.root.join('app', 'models', 'validation')
    config.autoload_paths << Rails.root.join('app', 'models', 'validation', 'validators')

    # Add Formatters Module to autoload path
    config.autoload_paths << Rails.root.join('app', 'models', 'formatters')
  end
end
