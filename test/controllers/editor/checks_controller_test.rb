# frozen_string_literal: true

require "test_helper"

# Tests to assure that project editors can create and update project checks.
class Editor::ChecksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project_editor = users(:project_one_editor)
    @project = projects(:one)
    @check = checks(:one)
  end

  def check_params
    {
      name: @check.name,
      slug: @check.slug,
      description: @check.description,
      message: @check.message,
      archived: @check.archived
    }
  end

  test "should get index" do
    login(@project_editor)
    get editor_project_checks_path(@project)
    assert_response :success
  end

  test "should get new" do
    login(@project_editor)
    get new_editor_project_check_path(@project)
    assert_response :success
  end

  test "should create check" do
    login(@project_editor)
    assert_difference("Check.count") do
      post editor_project_checks_path(@project), params: {
        check: check_params.merge(name: "Check Three", slug: "check-three")
      }
    end
    assert_redirected_to editor_project_check_path(@project, Check.last)
  end

  test "should not create check with blank name" do
    login(@project_editor)
    assert_difference("Check.count", 0) do
      post editor_project_checks_path(@project), params: {
        check: check_params.merge(name: "", slug: "check-three")
      }
    end
    assert_template "new"
    assert_response :success
  end

  test "should show check" do
    login(@project_editor)
    get editor_project_check_path(@project, @check)
    assert_response :success
  end

  test "should get edit" do
    login(@project_editor)
    get edit_editor_project_check_path(@project, @check)
    assert_response :success
  end

  test "should update check" do
    login(@project_editor)
    patch editor_project_check_path(@project, @check), params: {
      check: check_params
    }
    assert_redirected_to editor_project_check_path(@project, @check)
  end

  test "should update check with ajax" do
    login(@project_editor)
    patch editor_project_check_path(@project, @check, format: "js"), params: {
      check: check_params
    }
    assert_template "update"
    assert_response :success
  end

  test "should not update check with blank name" do
    login(@project_editor)
    patch editor_project_check_path(@project, @check), params: {
      check: check_params.merge(name: "")
    }
    assert_template "edit"
    assert_response :success
  end

  test "should destroy check" do
    login(@project_editor)
    assert_difference("Check.current.count", -1) do
      delete editor_project_check_path(@project, @check)
    end
    assert_redirected_to editor_project_checks_path(@project)
  end

  test "should destroy check with ajax" do
    login(@project_editor)
    assert_difference("Check.current.count", -1) do
      delete editor_project_check_path(@project, @check, format: "js")
    end
    assert_template "destroy"
    assert_response :success
  end

  test "should request check run" do
    login(@project_editor)
    post request_run_editor_project_check_path(@project, @check)
    assert_redirected_to editor_project_check_path(@project, @check)
  end
end
