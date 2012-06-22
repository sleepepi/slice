require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:projects)
  end

  test "should get paginated index" do
    get :index, format: 'js'
    assert_not_nil assigns(:projects)
    assert_template 'index'
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create project" do
    assert_difference('Project.count') do
      post :create, project: { description: @project.description, name: 'Project New Name' }
    end

    assert_redirected_to project_path(assigns(:project))
  end

  test "should not create project with blank name" do
    assert_difference('Project.count', 0) do
      post :create, project: { description: @project.description, name: '' }
    end

    assert_not_nil assigns(:project)
    assert assigns(:project).errors.size > 0
    assert_equal ["can't be blank"], assigns(:project).errors[:name]
    assert_template 'new'
  end

  test "should show project" do
    get :show, id: @project
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test "should not show invalid project" do
    get :show, id: -1
    assert_nil assigns(:project)
    assert_redirected_to projects_path
  end

  test "should get edit" do
    get :edit, id: @project
    assert_response :success
  end

  test "should update project" do
    put :update, id: @project, project: { description: @project.description, name: @project.name }
    assert_redirected_to project_path(assigns(:project))
  end

  test "should not update project with blank name" do
    put :update, id: @project, project: { description: @project.description, name: '' }
    assert_not_nil assigns(:project)
    assert assigns(:project).errors.size > 0
    assert_equal ["can't be blank"], assigns(:project).errors[:name]
    assert_template 'edit'
  end

  test "should not update invalid project" do
    put :update, id: -1, project: { description: @project.description, name: @project.name }
    assert_nil assigns(:project)
    assert_redirected_to projects_path
  end

  test "should destroy project" do
    assert_difference('Project.current.count', -1) do
      delete :destroy, id: @project
    end

    assert_redirected_to projects_path
  end
end
