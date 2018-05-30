# frozen_string_literal: true

require "test_helper"

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @organization = organizations(:one)
  end

  def organization_params
    {
      name: "New Organization",
      slug: "new-organization",
      description: "New organization to help test organizational profiles."
    }
  end

  test "should get index" do
    login(@admin)
    get organizations_url
    assert_response :success
  end

  test "should get new" do
    login(@admin)
    get new_organization_url
    assert_response :success
  end

  test "should create organization" do
    login(@admin)
    assert_difference("Organization.count") do
      post organizations_url, params: { organization: organization_params }
    end
    assert_redirected_to organization_url(Organization.last)
  end

  test "should show organization" do
    login(@admin)
    get organization_url(@organization)
    assert_response :success
  end

  test "should get edit" do
    login(@admin)
    get edit_organization_url(@organization)
    assert_response :success
  end

  test "should update organization" do
    login(@admin)
    patch organization_url(@organization), params: { organization: organization_params }
    assert_redirected_to organization_url(@organization)
  end

  test "should destroy organization" do
    login(@admin)
    assert_difference("Organization.count", -1) do
      delete organization_url(@organization)
    end
    assert_redirected_to organizations_url
  end
end
