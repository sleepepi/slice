# frozen_string_literal: true

require 'test_helper'

# Tests to assure that adverse events can be shared with medical monitors.
class AdverseEventControllerTest < ActionController::TestCase
  setup do
    @shared = adverse_events(:shared)
  end

  test 'should get show for shared adverse event' do
    get :show, params: { authentication_token: @shared.id_and_token }
    assert_response :success
  end

  test 'should not get show for unshared adverse event' do
    get :show, params: { authentication_token: adverse_events(:one).id_and_token }
    assert_redirected_to about_path
  end
end
