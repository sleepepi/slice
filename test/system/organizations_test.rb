# frozen_string_literal: true

require "application_system_test_case"

# Test modifying organizations as an admin.
class OrganizationsTest < ApplicationSystemTestCase
  setup do
    @organization = organizations(:one)
    @admin = users(:admin)
  end

  test "visit organizations index" do
    visit_login(@admin)
    visit organizations_url
    assert_selector "h1", text: "Organizations"
    screenshot("visit-organizations-index")
  end

  test "create an organization" do
    visit_login(@admin)
    visit organizations_url
    screenshot("create-an-organization")
    click_on "New Organization"
    fill_in "organization[name]", with: "Organization One"
    screenshot("create-an-organization")
    click_on "Create Organization"
    assert_text "Organization was successfully created"
    assert_selector "h1", text: "Organization One"
    screenshot("create-an-organization")
  end

  test "update an organization" do
    visit_login(@admin)
    visit organizations_url
    screenshot("update-an-organization")
    click_on "Actions", match: :first
    screenshot("update-an-organization")
    click_on "Edit"
    fill_in "organization[name]", with: "Updated Name"
    screenshot("update-an-organization")
    click_on "Update Organization"
    assert_text "Organization was successfully updated"
    assert_selector "h1", text: "Updated Name"
    screenshot("update-an-organization")
  end

  test "destroy an organization" do
    visit_login(@admin)
    visit organizations_url
    screenshot("destroy-an-organization")
    click_on "Actions", match: :first
    page.accept_confirm do
      click_on "Delete"
    end
    assert_text "Organization was successfully deleted"
    screenshot("destroy-an-organization")
  end
end
