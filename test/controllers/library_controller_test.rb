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
  test "should show form" do
    get library_tray_url(profiles(:one), trays(:one))
    assert_response :success
  end

  # Displays a public slice form.
  test "should print form" do
    skip if ENV["TRAVIS"] # Skip this test on Travis since Travis can't generate PDFs
    get library_print_url(profiles(:one), trays(:one))
    assert_response :success
  end

  # Displays a public slice form.
  test "should copy form" do
    get library_tray_url(profiles(:one), trays(:one), format: "json")
    assert_response :success
  end
end
