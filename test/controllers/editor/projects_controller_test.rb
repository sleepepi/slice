# frozen_string_literal: true

require 'test_helper'

# Tests to assure that project editors can modify projects.
class Editor::ProjectsControllerTest < ActionController::TestCase
  setup do
    @project = projects(:one)
  end

  test 'should create project user' do
    login(users(:project_one_editor))
    assert_difference('ProjectUser.count') do
      post :invite_user, id: @project, editor: '1',
                         invite_email: users(:two).name + " [#{users(:two).email}]",
                         format: 'js'
    end
    assert_not_nil assigns(:member)
    assert_template 'members'
  end

  test 'should only create blinded members as blinded project user' do
    login(users(:project_one_editor_blinded))
    assert_difference('ProjectUser.count') do
      post :invite_user, id: @project, editor: '1',
                         invite_email: users(:two).name + " [#{users(:two).email}]",
                         unblinded: '1',
                         format: 'js'
    end
    assert_not_nil assigns(:member)
    assert_equal false, assigns(:member).unblinded?
    assert_template 'members'
  end

  test 'should create project user and automatically add associated user' do
    login(users(:valid))
    assert_difference('ProjectUser.count') do
      post :invite_user, id: projects(:single_design), editor: '1',
                         invite_email: users(:associated).name + " [#{users(:associated).email}]",
                         format: 'js'
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:member)
    assert_template 'members'
  end

  test 'should create project user invitation' do
    login(users(:project_one_editor))
    assert_difference('ProjectUser.count') do
      post :invite_user, id: @project, editor: '1', invite_email: 'invite@example.com', format: 'js'
    end
    assert_not_nil assigns(:member)
    assert_not_nil assigns(:member).invite_token
    assert_template 'members'
  end

  test 'should not create project user with invalid project id' do
    login(users(:project_one_editor))
    assert_difference('ProjectUser.count', 0) do
      post :invite_user, id: -1, editor: '1',
                         invite_email: users(:two).name + " [#{users(:two).email}]",
                         format: 'js'
    end

    assert_nil assigns(:member)
    assert_response :success
  end

  test 'should create site user as editor' do
    login(users(:project_one_editor))
    assert_difference('SiteUser.count') do
      post :invite_user, id: @project, site_id: sites(:one), editor: '1',
                         invite_email: 'invite@example.com',
                         format: 'js'
    end

    assert_not_nil assigns(:member)
    assert_equal true, assigns(:member).editor

    assert_template 'members'
    assert_response :success
  end

  test 'should create site user as viewer' do
    login(users(:project_one_editor))
    assert_difference('SiteUser.count') do
      post :invite_user, id: @project, site_id: sites(:one),
                         invite_email: 'invite@example.com',
                         format: 'js'
    end

    assert_not_nil assigns(:member)
    assert_equal false, assigns(:member).editor

    assert_template 'members'
    assert_response :success
  end

  test 'should get edit' do
    login(users(:project_one_editor))
    get :edit, id: @project
    assert_response :success
  end

  test 'should update project' do
    login(users(:project_one_editor))
    patch :update, id: @project, project: { name: @project.name, description: @project.description }
    assert_redirected_to settings_editor_project_path(@project)
  end

  test 'should not update project with blank name' do
    login(users(:project_one_editor))
    patch :update, id: @project, project: { name: '' }
    assert_not_nil assigns(:project)
    assert assigns(:project).errors.size > 0
    assert_equal ["can't be blank"], assigns(:project).errors[:name]
    assert_template 'edit'
  end

  test 'should not update invalid project' do
    login(users(:project_one_editor))
    patch :update, id: -1, project: { name: @project.name, description: @project.description }
    assert_nil assigns(:project)
    assert_redirected_to projects_path
  end

  test 'should remove attached logo' do
    begin
      login(users(:project_one_editor))
      assert_not_equal 0, @project.logo.size
      patch :update, id: @project, project: { remove_logo: '1' }

      assert_not_nil assigns(:project)
      assert_equal 0, assigns(:project).logo.size

      assert_redirected_to settings_editor_project_path(@project)
    ensure
      # Reset File after test run
      FileUtils.cp File.join('test', 'support', 'projects', 'rails.png'),
                   File.join('test', 'support', 'projects', '980190962', 'logo', 'rails.png')
    end
  end

  test 'should not remove attached logo as site viewer' do
    assert_not_equal 0, @project.logo.size
    login(users(:site_one_viewer))
    patch :update, id: @project.id, project: { remove_logo: '1' }
    assert_nil assigns(:project)
    assert_not_equal 0, @project.logo.size
    assert_redirected_to projects_path
  end
end
