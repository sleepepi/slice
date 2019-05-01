# frozen_string_literal: true

require "test_helper"

# Tests to assure that project owners can transfer and delete projects.
class Owner::ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:one)
    @owner = users(:regular)
  end

  test "should get api as owner" do
    login(@owner)
    get api_owner_project_url(@project)
    assert_response :success
  end

  test "should generate project api key as owner" do
    login(@owner)
    post generate_api_key_owner_project_url(@project, format: "js")
    @project.reload
    assert_not_nil @project.authentication_token
    assert_response :success
  end

  test "should transfer project to another user" do
    login(@owner)
    post transfer_owner_project_url(@project, user_id: users(:associated))
    assert_equal true, assigns(:project).editors.pluck(:id).include?(users(:regular).id)
    assert_redirected_to settings_editor_project_path(assigns(:project))
  end

  test "should not transfer project as non-owner" do
    login(@owner)
    post transfer_owner_project_url(projects(:three)), params: { user_id: users(:regular) }
    assert_redirected_to projects_path
  end

  test "should destroy project" do
    login(@owner)
    assert_difference("Project.current.count", -1) do
      delete owner_project_url(@project)
    end
    assert_redirected_to root_path
  end

  test "should not destroy project as non-owner" do
    login(@owner)
    assert_difference("Project.current.count", 0) do
      delete owner_project_url(projects(:three))
    end
    assert_redirected_to projects_path
  end

  test "should destroy project using AJAX" do
    login(@owner)
    assert_difference("Project.current.count", -1) do
      delete owner_project_url(@project, format: "js")
    end
    assert_template "destroy"
    assert_response :success
  end
end
