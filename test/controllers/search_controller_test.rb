# frozen_string_literal: true

require "test_helper"

# Tests to assure that search results are returned.
class SearchControllerTest < ActionDispatch::IntegrationTest
  test "should get search" do
    login(users(:regular))
    get search_url, params: { search: "" }
    assert_response :success
  end

  test "should get search and redirect to project" do
    login(users(:regular))
    get search_url, params: { search: "Project With One Design" }
    assert_redirected_to projects(:single_design)
  end

  test "should get search and redirect to variable" do
    login(users(:regular))
    get search_url, params: { search: "var_course_work" }
    assert_redirected_to [variables(:checkbox).project, variables(:checkbox)]
  end
end
