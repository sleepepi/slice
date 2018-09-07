# frozen_string_literal: true

require "application_system_test_case"

# Test adding cubes to trays.
class CubesTest < ApplicationSystemTestCase
  setup do
    @tray = trays(:one)
    @cube = cubes(:one)
    @regular = users(:regular)
  end

  test "visit cubes index" do
    visit_login(@regular)
    visit tray_cubes_url(@tray.profile, @tray)
    assert_selector "h1", text: "Cubes"
    screenshot("visit-cubes-index")
  end

  test "create a cube" do
    visit_login(@regular)
    visit tray_cubes_url(@tray.profile, @tray)
    screenshot("create-a-cube")
    click_on "New Cube"
    fill_in "cube[position]", with: @cube.position
    fill_in "cube[text]", with: @cube.text
    fill_in "cube[description]", with: @cube.description
    select "section", from: "cube[cube_type]"
    screenshot("create-a-cube")
    click_on "Create Cube"
    assert_text "Cube was successfully created"
    # assert_selector "h1", text: "Demographics ##{}"
    screenshot("create-a-cube")
  end

  test "update a cube" do
    visit_login(@regular)
    visit tray_cubes_url(@tray.profile, @tray)
    screenshot("update-a-cube")
    click_on "Edit", match: :first
    fill_in "cube[position]", with: @cube.position
    fill_in "cube[text]", with: @cube.text
    fill_in "cube[description]", with: @cube.description
    select "section", from: "cube[cube_type]"
    screenshot("update-a-cube")
    click_on "Update Cube"
    assert_text "Cube was successfully updated"
    # assert_selector "h1", text: "Demographics ##{}"
    screenshot("update-a-cube")
  end

  test "destroy a cube" do
    visit_login(@regular)
    visit tray_cubes_url(@tray.profile, @tray)
    screenshot("destroy-a-cube")
    page.accept_confirm do
      click_on "Destroy", match: :first
    end
    assert_text "Cube was successfully deleted"
    screenshot("destroy-a-cube")
  end
end
