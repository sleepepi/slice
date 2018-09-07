# frozen_string_literal: true

require "application_system_test_case"

# Test editing trays.
class TraysTest < ApplicationSystemTestCase
  setup do
    @tray = trays(:one)
    @regular = users(:regular)
  end

  test "visit trays index" do
    visit_login(@regular)
    visit library_profile_url(@regular.profile)
    assert_selector "div", text: "Forms"
    screenshot("visit-trays-index")
  end

  test "create a tray" do
    visit_login(@regular)
    visit library_profile_url(@regular.profile)
    screenshot("create-a-tray")
    click_on "New form"
    fill_in "tray[name]", with: "Intake Form"
    fill_in "tray[description]", with: "My extensive description."
    fill_in "tray[time_in_seconds]", with: 210
    fill_in "tray[keywords]", with: "test, empty, blank"
    screenshot("create-a-tray")
    click_on "Create Tray"
    assert_text "Tray was successfully created"
    assert_selector "div", text: "Intake Form"
    screenshot("create-a-tray")
  end

  test "update a tray" do
    visit_login(@regular)
    visit library_profile_url(@regular.profile)
    screenshot("update-a-tray")
    click_on @tray.name
    screenshot("update-a-tray")
    click_on "Settings"
    screenshot("update-a-tray")
    fill_in "tray[name]", with: "Intake Form"
    fill_in "tray[description]", with: "My extensive description."
    fill_in "tray[time_in_seconds]", with: 210
    fill_in "tray[keywords]", with: "test, empty, blank"
    screenshot("update-a-tray")
    click_on "Update Tray"
    assert_text "Tray was successfully updated"
    assert_selector "div", text: "Intake Form"
    screenshot("update-a-tray")
  end

  test "destroy a tray" do
    skip
    visit_login(@regular)
    visit library_profile_url(@regular.profile)
    screenshot("destroy-a-tray")
    click_on @tray.name
    screenshot("destroy-a-tray")
    page.accept_confirm do
      click_on "Delete", match: :first
    end
    assert_text "Tray was successfully deleted"
    screenshot("destroy-a-tray")
  end
end
