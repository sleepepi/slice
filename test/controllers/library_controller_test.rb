# frozen_string_literal: true

require "test_helper"

class LibraryControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get library_root_url
    assert_response :success
  end

  test "should get profile" do
    get library_profile_url(profiles(:one))
    assert_response :success
  end

  # Displays a public slice form.
  test "should get show" do
    get library_show_url(profiles(:one), trays(:one))
    assert_response :success
  end
end
