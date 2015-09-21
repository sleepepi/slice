require 'simplecov'
require 'minitest/pride'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionController::TestCase
  include Devise::TestHelpers

  def login(resource)
    @request.env['devise.mapping'] = Devise.mappings[resource]
    sign_in(resource.class.name.downcase.to_sym, resource)
  end
end

class ActionDispatch::IntegrationTest
  def sign_in_as(user, password)
    user.update password: password, password_confirmation: password
    post_via_redirect '/login', user: { email: user.email, password: password }
    user
  end
end

module Rack
  module Test
    class UploadedFile
      attr_reader :tempfile
    end
  end
end
