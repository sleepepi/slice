# frozen_string_literal: true

require 'test_helper'

class LinksControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @link = links(:one)
  end

  test "should get index" do
    get :index, project_id: @project
    assert_response :success
    assert_not_nil assigns(:links)
  end

  test "should not get index with invalid project" do
    get :index, project_id: -1
    assert_nil assigns(:links)
    assert_redirected_to root_path
  end

  test "should get new" do
    get :new, project_id: @project
    assert_response :success
  end

  test "should create link" do
    assert_difference('Link.count') do
      post :create, project_id: @project, link: { name: @link.name, category: @link.category, url: @link.url, archived: @link.archived }
    end

    assert_redirected_to project_link_path(assigns(:link).project, assigns(:link))
  end

  test "should not create link with blank name" do
    assert_difference('Link.count', 0) do
      post :create, project_id: @project, link: { name: '', category: @link.category, url: @link.url, archived: @link.archived }
    end

    assert_not_nil assigns(:link)
    assert assigns(:link).errors.size > 0
    assert_equal ["can't be blank"], assigns(:link).errors[:name]
    assert_template 'new'
  end

  test "should not create link with invalid project" do
    assert_difference('Link.count', 0) do
      post :create, project_id: -1, link: { name: @link.name, category: @link.category, url: @link.url, archived: @link.archived }
    end

    assert_nil assigns(:link)
    assert_nil assigns(:project)
    assert_redirected_to root_path
  end

  test "should show link" do
    get :show, id: @link, project_id: @project
    assert_not_nil assigns(:link)
    assert_response :success
  end

  test "should not show link with invalid project" do
    get :show, id: @link, project_id: -1
    assert_nil assigns(:link)
    assert_redirected_to root_path
  end

  test "should get edit" do
    get :edit, id: @link, project_id: @project
    assert_not_nil assigns(:link)
    assert_response :success
  end

  test "should not get edit with invalid project" do
    get :edit, id: @link, project_id: -1
    assert_nil assigns(:link)
    assert_redirected_to root_path
  end

  test "should update link" do
    put :update, id: @link, project_id: @project, link: { name: @link.name, category: @link.category, url: @link.url, archived: @link.archived }
    assert_redirected_to project_link_path(assigns(:link).project, assigns(:link))
  end

  test "should update link and rename category for all associated categories" do
    patch :update, id: @link, project_id: @project, link: { name: @link.name, category: 'Renamed Category', url: @link.url, archived: @link.archived }, rename_category: '1'

    assert_equal 'Renamed Category', assigns(:link).category
    assert_equal 'Renamed Category', links(:two).category

    assert_redirected_to project_link_path(assigns(:link).project, assigns(:link))
  end

  test "should update link and change category for single link" do
    patch :update, id: @link, project_id: @project, link: { name: @link.name, category: 'Weekly Report', url: @link.url, archived: @link.archived }

    assert_equal 'Weekly Report', assigns(:link).category
    assert_equal 'Custom Reports', links(:two).category

    assert_redirected_to project_link_path(assigns(:link).project, assigns(:link))
  end

  test "should not update link with blank name" do
    put :update, id: @link, project_id: @project, link: { name: '', category: @link.category, url: @link.url, archived: @link.archived }

    assert_not_nil assigns(:link)
    assert assigns(:link).errors.size > 0
    assert_equal ["can't be blank"], assigns(:link).errors[:name]
    assert_template 'edit'
  end

  test "should not update link with invalid project" do
    put :update, id: @link, project_id: -1, link: { name: @link.name, category: @link.category, url: @link.url, archived: @link.archived }

    assert_nil assigns(:link)
    assert_nil assigns(:project)
    assert_redirected_to root_path
  end

  test "should destroy link" do
    assert_difference('Link.current.count', -1) do
      delete :destroy, id: @link, project_id: @project
    end

    assert_not_nil assigns(:link)
    assert_not_nil assigns(:project)

    assert_redirected_to project_links_path
  end

  test "should not destroy link with invalid project" do
    assert_difference('Link.current.count', 0) do
      delete :destroy, id: @link, project_id: -1
    end

    assert_nil assigns(:link)
    assert_nil assigns(:project)

    assert_redirected_to root_path
  end
end
