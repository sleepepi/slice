# frozen_string_literal: true

require "test_helper"

# Test that profiles can be created, updated, and viewed.
class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @profile = profiles(:one)
    @regular = users(:regular)
    @regular_two = users(:two)
  end

  def profile_params
    {
      username: "username",
      description: "I create **Slice forms**."
    }
  end

  test "should get index" do
    get profiles_url
    assert_response :success
  end

  test "should get new and redirect as public user" do
    get new_profile_url
    assert_redirected_to new_user_session_url
  end

  test "should get new and redirect to edit as user with existing profile" do
    login(@regular)
    get new_profile_url
    assert_redirected_to edit_profile_url(@regular.profile)
  end

  test "should get new as user with no profile" do
    login(@regular_two)
    get new_profile_url
    assert_response :success
  end

  test "should create profile" do
    login(@regular_two)
    assert_difference("Profile.count") do
      post profiles_url, params: { profile: profile_params }
    end
    assert_redirected_to library_profile_url(Profile.last)
  end

  test "should show profile" do
    get profile_url(@profile)
    assert_response :success
  end

  test "should get edit" do
    login(@regular)
    get edit_profile_url(@profile)
    assert_response :success
  end

  test "should update profile" do
    login(@regular)
    patch profile_url(@profile), params: { profile: profile_params }
    @profile.reload
    assert_redirected_to library_profile_url(@profile)
  end

  test "should destroy profile" do
    login(@regular)
    assert_difference("Profile.count", -1) do
      delete profile_url(@profile)
    end
    assert_redirected_to profiles_url
  end

  test "should get public profile picture" do
    get picture_profile_url(profiles(:picture))
    assert_not_nil response
    assert_kind_of String, response.body
    assert_equal File.binread(profiles(:picture).object.profile_picture.thumb.path), response.body
  end
end
