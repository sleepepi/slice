# frozen_string_literal: true

require "test_helper"

# Test that users and organizations can create trays.
class TraysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tray = trays(:one)
    @regular = users(:regular)
  end

  def tray_params
    {
      name: "New Tray",
      slug: "new-tray",
      time_in_seconds: 30
    }
  end

  test "should get index" do
    login(@regular)
    get trays_url(@regular.profile)
    assert_response :success
  end

  test "should get new" do
    login(@regular)
    get new_tray_url(@regular.profile)
    assert_response :success
  end

  test "should create tray" do
    login(@regular)
    assert_difference("Tray.count") do
      post trays_url(@regular.profile), params: { tray: tray_params }
    end
    assert_redirected_to tray_url(Tray.last.profile, Tray.last)
  end

  test "should show tray" do
    login(@regular)
    get tray_url(@regular.profile, @tray)
    assert_response :success
  end

  test "should get edit" do
    login(@regular)
    get edit_tray_url(@regular.profile, @tray)
    assert_response :success
  end

  test "should update tray" do
    login(@regular)
    patch tray_url(@regular.profile, @tray), params: {
      tray: tray_params.merge(name: "Demographics Updated")
    }
    @tray.reload
    assert_redirected_to tray_url(@tray.profile, @tray)
  end

  test "should destroy tray" do
    login(@regular)
    assert_difference("Tray.count", -1) do
      delete tray_url(@regular.profile, @tray)
    end
    assert_redirected_to trays_url
  end
end
