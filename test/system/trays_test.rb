# frozen_string_literal: true

require "application_system_test_case"

class TraysTest < ApplicationSystemTestCase
  setup do
    @tray = trays(:one)
  end

  test "visit the index" do
    visit trays_url
    assert_selector "h1", text: "Trays"
  end

  test "create a tray" do
    visit trays_url
    click_on "New Tray"

    fill_in "Name", with: @tray.name
    fill_in "Slug", with: @tray.slug
    fill_in "User", with: @tray.user_id
    click_on "Create Tray"

    assert_text "Tray was successfully created"
    click_on "Back"
  end

  test "update a tray" do
    visit trays_url
    click_on "Edit", match: :first

    fill_in "Name", with: @tray.name
    fill_in "Slug", with: @tray.slug
    fill_in "User", with: @tray.user_id
    click_on "Update Tray"

    assert_text "Tray was successfully updated"
    click_on "Back"
  end

  test "destroy a tray" do
    visit trays_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Tray was successfully deleted"
  end
end
