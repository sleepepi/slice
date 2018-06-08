# frozen_string_literal: true

require "test_helper"

# Tests to view and generate lists.
class ListsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project_one_editor = users(:project_one_editor)
    @project_two_editor = users(:regular)
    @project = projects(:one)
    @randomization_scheme = randomization_schemes(:one)
    @list = lists(:one)
  end

  test "should generate lists" do
    login(@project_two_editor)
    assert_difference("List.count", 2) do
      post generate_project_randomization_scheme_lists_url(projects(:two), randomization_schemes(:three))
    end
    assert_redirected_to project_randomization_scheme_url(projects(:two), randomization_schemes(:three))
  end

  test "should generate lists for minimization scheme with multiple sites" do
    login(@project_two_editor)
    assert_difference("List.count", 2) do
      post generate_project_randomization_scheme_lists_url(
        projects(:two),
        randomization_schemes(:minimization)
      )
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:randomization_scheme)
    assert_redirected_to project_randomization_scheme_url(assigns(:project), assigns(:randomization_scheme))
  end

  test "should generate single list for minimization scheme not stratifying by site" do
    login(@project_two_editor)
    assert_difference("List.count", 1) do
      post generate_project_randomization_scheme_lists_url(
        projects(:two),
        randomization_schemes(:minimization_not_by_site)
      )
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:randomization_scheme)
    assert_redirected_to project_randomization_scheme_url(projects(:two), randomization_schemes(:minimization_not_by_site))
  end

  test "should not generate lists for scheme with existing randomizations" do
    login(@project_one_editor)
    assert_difference("List.count", 0) do
      post generate_project_randomization_scheme_lists_url(
        @project,
        @randomization_scheme
      )
    end
    assert_redirected_to project_randomization_scheme_url(@project, @randomization_scheme)
  end

  test "should expand lists for minimization scheme with multiple sites" do
    login(@project_two_editor)
    assert_difference("List.count", 2) do
      post expand_project_randomization_scheme_lists_url(
        projects(:two),
        randomization_schemes(:minimization)
      )
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:randomization_scheme)
    assert_redirected_to project_randomization_scheme_url(assigns(:project), assigns(:randomization_scheme))
  end

  test "should get index" do
    login(@project_one_editor)
    get project_randomization_scheme_lists_url(@project, @randomization_scheme)
    assert_response :success
  end

  test "should show list" do
    login(@project_one_editor)
    get project_randomization_scheme_list_url(@project, @randomization_scheme, @list)
    assert_response :success
  end
end
