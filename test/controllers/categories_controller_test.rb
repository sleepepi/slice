# frozen_string_literal: true

require "test_helper"

# Tests creation of categories used to group designs on a project.
class CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project_editor = users(:regular)
    @project = projects(:one)
    @category = categories(:one)
  end

  def category_params
    {
      name: "New Category",
      slug: "new-category",
      description: "",
      position: 3,
      use_for_adverse_events: "0"
    }
  end

  test "should get index" do
    login(@project_editor)
    get project_categories_url(@project)
    assert_response :success
  end

  test "should not get index with invalid project" do
    login(@project_editor)
    get project_categories_url(-1)
    assert_redirected_to root_url
  end

  test "should get new" do
    login(@project_editor)
    get new_project_category_url(@project)
    assert_response :success
  end

  test "should create category" do
    login(@project_editor)
    assert_difference("Category.count") do
      post project_categories_url(@project), params: {
        category: category_params
      }
    end
    assert_redirected_to project_category_url(@project, Category.last)
  end

  test "should not create category with blank name" do
    login(@project_editor)
    assert_difference("Category.count", 0) do
      post project_categories_url(@project), params: {
        category: category_params.merge(name: "", slug: "")
      }
    end
    assert_equal ["can't be blank"], assigns(:category).errors[:name]
    assert_template "new"
  end

  test "should not create category with invalid project" do
    login(@project_editor)
    assert_difference("Category.count", 0) do
      post project_categories_url(-1), params: {
        category: category_params
      }
    end
    assert_redirected_to root_url
  end

  test "should show category" do
    login(@project_editor)
    get project_category_url(@project, @category)
    assert_response :success
  end

  test "should not show category with invalid project" do
    login(@project_editor)
    get project_category_url(-1, @category)
    assert_redirected_to root_url
  end

  test "should get edit" do
    login(@project_editor)
    get edit_project_category_url(@project, @category)
    assert_response :success
  end

  test "should not get edit with invalid project" do
    login(@project_editor)
    get edit_project_category_url(-1, @category)
    assert_redirected_to root_url
  end

  test "should update category" do
    login(@project_editor)
    patch project_category_url(@project, @category), params: {
      category: category_params.merge(name: "Updated Category", slug: "updated-category")
    }
    @category.reload
    assert_redirected_to project_category_url(@project, @category)
  end

  test "should not update category with blank name" do
    login(@project_editor)
    patch project_category_url(@project, @category), params: {
      category: category_params.merge(name: "")
    }
    assert_equal ["can't be blank"], assigns(:category).errors[:name]
    assert_template "edit"
  end

  test "should not update category with invalid project" do
    login(@project_editor)
    patch project_category_url(-1, @category), params: {
      category: category_params.merge(name: "Updated Category", slug: "updated-category")
    }
    assert_redirected_to root_url
  end

  test "should destroy category" do
    login(@project_editor)
    assert_difference("Category.current.count", -1) do
      delete project_category_url(@project, @category)
    end
    assert_redirected_to project_categories_url(assigns(:project))
  end

  test "should not destroy category with invalid project" do
    login(@project_editor)
    assert_difference("Category.current.count", 0) do
      delete project_category_url(-1, @category)
    end
    assert_redirected_to root_url
  end
end
