# frozen_string_literal: true

require "test_helper"

# Tests to assure users can remain logged in.
class InternalControllerTest < ActionDispatch::IntegrationTest
  setup do
    @regular = users(:regular)
  end

  test "should keep me active as regular user" do
    login(@regular)
    post keep_me_active_path(format: "js")
    assert_response :success
  end

  test "should not keep me active as public user" do
    post keep_me_active_path(format: "js")
    assert_response :unauthorized
  end

  test "should get autocomplete as regular user" do
    login(@regular)
    get autocomplete_url(format: "json"), params: { search: "associated" }
    users_json = JSON.parse(response.body)
    assert_equal "associated@example.com", users_json.first["email"]
    assert_equal "Associated User", users_json.first["full_name"]
    assert_response :success
  end
end
