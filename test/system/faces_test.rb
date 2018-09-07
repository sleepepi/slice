# frozen_string_literal: true

require "application_system_test_case"

# Test editing cube faces.
class FacesTest < ApplicationSystemTestCase
  setup do
    @tray = trays(:one)
    @cube = cubes(:one)
    @face = faces(:one)
    @regular = users(:regular)
  end

  test "visit faces index" do
    visit_login(@regular)
    visit tray_cube_faces_url(@tray.profile, @tray, @cube)
    assert_selector "h1", text: "Faces"
    screenshot("visit-faces-index")
  end

  test "create a face" do
    visit_login(@regular)
    visit tray_cube_faces_url(@tray.profile, @tray, @cube)
    screenshot("create-a-face")
    click_on "New Face"
    fill_in "face[position]", with: @face.position
    fill_in "face[text]", with: @face.text
    screenshot("create-a-face")
    click_on "Create Face"
    assert_text "Face was successfully created"
    # assert_selector "h1", text: "Demographics ##{}"
    screenshot("create-a-face")
  end

  test "update a face" do
    visit_login(@regular)
    visit tray_cube_faces_url(@tray.profile, @tray, @cube)
    screenshot("update-a-face")
    click_on "Edit", match: :first
    fill_in "face[position]", with: @face.position
    fill_in "face[text]", with: @face.text
    screenshot("update-a-face")
    click_on "Update Face"
    assert_text "Face was successfully updated"
    # assert_selector "h1", text: "Demographics ##{}"
    screenshot("update-a-face")
  end

  test "destroy a face" do
    visit_login(@regular)
    visit tray_cube_faces_url(@tray.profile, @tray, @cube)
    screenshot("destroy-a-face")
    page.accept_confirm do
      click_on "Destroy", match: :first
    end
    assert_text "Face was successfully deleted"
    screenshot("destroy-a-face")
  end
end
