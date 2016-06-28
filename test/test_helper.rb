# frozen_string_literal: true

require 'simplecov'
require 'minitest/pride'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

# Set up ActiveSupport tests
class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

# Set up ActionController tests
class ActionController::TestCase
  include Devise::Test::ControllerHelpers

  def login(resource)
    @request.env['devise.mapping'] = Devise.mappings[resource]
    sign_in(resource, scope: resource.class.name.downcase.to_sym)
  end
end

# Set up ActionDispatch tests
class ActionDispatch::IntegrationTest
  def login(user)
    sign_in_as(user, '1234567890')
  end

  def sign_in_as(user, password)
    user.update password: password, password_confirmation: password
    post '/login', params: { user: { email: user.email, password: password } }
    follow_redirect!
    user
  end
end

module Rack
  module Test
    # Allow files to be uploaded in tests
    class UploadedFile
      attr_reader :tempfile
    end
  end
end
