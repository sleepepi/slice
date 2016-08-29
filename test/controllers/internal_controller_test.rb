# frozen_string_literal: true

require 'test_helper'

# Tests to assure users can remain logged in.
class InternalControllerTest < ActionDispatch::IntegrationTest
  setup do
    @regular_user = users(:valid)
  end

  test 'should keep me active for regular user' do
    login(@regular_user)
    post keep_me_active_path(format: 'js')
    assert_response :success
  end

  test 'should not keep me active for public user' do
    post keep_me_active_path(format: 'js')
    assert_response :unauthorized
  end
end
