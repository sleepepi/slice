# frozen_string_literal: true

require "application_system_test_case"

# Test creating and editing a profile.
class ProfilesTest < ApplicationSystemTestCase
  setup do
    @profile = profiles(:one)
    @regular = users(:regular)
    @no_profile = users(:no_profile)
  end

  test "visit profiles index" do
    visit_login(@regular)
    visit profiles_url
    assert_selector "h1", text: "Profiles"
    screenshot("visit-profiles-index")
  end

  test "create a profile" do
    visit_login(@no_profile)
    visit library_root_url
    click_on "Create a form"
    screenshot("create-a-profile")
    fill_in "profile[username]", with: "newbie"
    screenshot("create-a-profile")
    click_on "Save Profile"
    assert_text "Profile was successfully created"
    assert_selector "div", text: "newbie"
    screenshot("create-a-profile")
  end

  test "update a profile" do
    visit_login(@regular)
    visit edit_profile_url(@profile)
    screenshot("update-a-profile")
    fill_in "profile[username]", with: "newprofilename"
    fill_in "profile[description]", with: "A little about myself."
    screenshot("update-a-profile")
    click_on "Save Profile"
    assert_text "Profile was successfully updated"
    assert_selector "div", text: "newprofilename"
    screenshot("update-a-profile")
  end

  test "destroy a profile" do
    skip
    visit_login(@regular)
    visit profiles_url
    screenshot("destroy-a-profile")
    page.accept_confirm do
      click_on "Destroy", match: :first
    end
    assert_text "Profile was successfully deleted"
    screenshot("destroy-a-profile")
  end
end
