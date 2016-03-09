# frozen_string_literal: true

require 'test_helper'

# Tests to assure that project owners can transfer and delete projects.
class Owner::ProjectsControllerTest < ActionController::TestCase
  setup do
    @project = projects(:one)
  end

  test 'should transfer project to another user' do
    login(users(:valid))
    post :transfer, id: @project, user_id: users(:associated)
    assert_not_nil assigns(:project)
    assert_equal true, assigns(:project).editors.pluck(:id).include?(users(:valid).id)
    assert_redirected_to settings_editor_project_path(assigns(:project))
  end

  test 'should not transfer project as non-owner' do
    login(users(:valid))
    post :transfer, id: projects(:three), user_id: users(:valid)
    assert_nil assigns(:project)
    assert_redirected_to projects_path
  end

  test 'should destroy project' do
    login(users(:valid))
    assert_difference('Project.current.count', -1) do
      delete :destroy, id: @project
    end

    assert_redirected_to root_path
  end

  test 'should not destroy project as non-owner' do
    login(users(:valid))
    assert_difference('Project.current.count', 0) do
      delete :destroy, id: projects(:three)
    end
    assert_nil assigns(:project)
    assert_redirected_to projects_path
  end

  test 'should destroy project using AJAX' do
    login(users(:valid))
    assert_difference('Project.current.count', -1) do
      delete :destroy, id: @project, format: 'js'
    end

    assert_template 'destroy'
    assert_response :success
  end
end
