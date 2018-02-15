# frozen_string_literal: true

require "test_helper"

# Tests to assure that users can set project preferences.
class ProjectPreferencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:one)
  end

  test "should archive project" do
    login(users(:valid))
    assert_difference("ProjectPreference.where(archived: true).count") do
      patch project_preferences_update_path(
        project_id: projects(:one), archived: "1", format: "js"
      )
    end
    assert_not_nil assigns(:project)
    assert_template "update"
    assert_response :success
  end

  test "should not archive project without valid id" do
    login(users(:valid))
    assert_difference("ProjectPreference.where(archived: true).count", 0) do
      patch project_preferences_update_path(
        project_id: -1, archived: "1", format: "js"
      )
    end
    assert_nil assigns(:project)
    assert_response :success
  end

  test "should activate project" do
    login(users(:valid))
    assert_difference("ProjectPreference.where(archived: false).count") do
      patch project_preferences_update_path(
        project_id: projects(:two), archived: "0", format: "js"
      )
    end
    assert_not_nil assigns(:project)
    assert_template "update"
    assert_response :success
  end

  test "should enable project emails" do
    login(users(:associated))
    assert_difference("ProjectPreference.where(emails_enabled: true).count") do
      patch project_preferences_update_path(
        project_id: projects(:one), emails_enabled: "1", format: "js"
      )
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:project_preference)
    assert_template "update"
    assert_response :success
  end

  test "should disable project emails" do
    login(users(:valid))
    assert_difference("ProjectPreference.where(emails_enabled: false).count") do
      patch project_preferences_update_path(
        project_id: projects(:one), emails_enabled: "0", format: "js"
      )
    end
    assert_not_nil assigns(:project)
    assert_template "update"
    assert_response :success
  end
end
