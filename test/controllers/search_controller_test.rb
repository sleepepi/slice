# frozen_string_literal: true

require "test_helper"

# Tests to assure that search results are returned.
class SearchControllerTest < ActionDispatch::IntegrationTest
  test "should get search" do
    login(users(:valid))
    get search_url, params: { search: "" }
    assert_not_nil assigns(:subjects)
    assert_not_nil assigns(:projects)
    assert_not_nil assigns(:designs)
    assert_not_nil assigns(:variables)
    assert_not_nil assigns(:objects)
    assert_response :success
  end

  test "should get search and redirect to project" do
    login(users(:valid))
    get search_url, params: { search: "Project With One Design" }
    assert_not_nil assigns(:subjects)
    assert_not_nil assigns(:projects)
    assert_not_nil assigns(:designs)
    assert_not_nil assigns(:variables)
    assert_not_nil assigns(:objects)
    assert_equal 1, assigns(:objects).size
    assert_redirected_to assigns(:objects).first
  end

  test "should get search and redirect to variable" do
    login(users(:valid))
    get search_url, params: { search: "var_course_work" }
    assert_not_nil assigns(:subjects)
    assert_not_nil assigns(:projects)
    assert_not_nil assigns(:designs)
    assert_not_nil assigns(:variables)
    assert_not_nil assigns(:objects)
    assert_equal 1, assigns(:objects).size
    assert_redirected_to [variables(:checkbox).project, variables(:checkbox)]
  end
end
