# frozen_string_literal: true

require "test_helper"

# Tests to view member profiles.
class MembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @regular = users(:regular)
  end

  test "should get show" do
    login(@regular)
    get member_url(@regular)
    assert_redirected_to root_url
  end

  test "should get member profile picture with username" do
    login(@regular)
    get profile_picture_member_url(users(:profile_picture))
    assert_not_nil response
    assert_kind_of String, response.body
    assert_equal File.binread(users(:profile_picture).profile_picture.thumb.path), response.body
  end
end
