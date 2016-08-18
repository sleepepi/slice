# frozen_string_literal: true

require 'test_helper'

# Tests to make sure projects can be viewed and edited.
class ProjectsControllerTest < ActionController::TestCase
  setup do
    @project = projects(:one)
    @project_editor = users(:project_one_editor)
    @project_viewer = users(:project_one_viewer)
  end

  test 'should save project order' do
    login(users(:valid))
    post :save_project_order, params: {
      project_ids: [
        ActiveRecord::FixtureSet.identify(:two),
        ActiveRecord::FixtureSet.identify(:one),
        ActiveRecord::FixtureSet.identify(:no_sites),
        ActiveRecord::FixtureSet.identify(:single_design),
        ActiveRecord::FixtureSet.identify(:empty),
        ActiveRecord::FixtureSet.identify(:named_project)
      ]
    }, format: 'js'
    assert_response :success
  end

  test 'should favorite project' do
    login(users(:valid))
    assert_difference('ProjectFavorite.where(favorite: true).count') do
      post :favorite, params: { id: @project, favorite: '1' }
    end
    assert_redirected_to root_path
  end

  test 'should get share as project editor' do
    login(@project_editor)
    get :share, params: { id: @project }
    assert_response :success
  end

  test 'should get share as project viewer' do
    login(@project_viewer)
    get :share, params: { id: @project }
    assert_response :success
  end

  test 'should archive project' do
    login(users(:valid))
    assert_difference('ProjectFavorite.where(archived: true).count') do
      post :archive, params: { id: @project }
    end
    assert_redirected_to root_path
  end

  test 'should undo archive project' do
    login(users(:valid))
    assert_difference('ProjectFavorite.where(archived: false).count') do
      post :archive, params: { id: @project, undo: '1' }
    end
    assert_redirected_to root_path
  end

  test 'should restore project' do
    login(users(:valid))
    assert_difference('ProjectFavorite.where(archived: false).count') do
      post :restore, params: { id: @project }
    end
    assert_redirected_to archives_path
  end

  test 'should undo restore project' do
    login(users(:valid))
    assert_difference('ProjectFavorite.where(archived: true).count') do
      post :restore, params: { id: @project, undo: '1' }
    end
    assert_redirected_to archives_path
  end

  test 'should get archives' do
    login(users(:valid))
    get :archives
    assert_response :success
  end

  test 'should get logo as project editor' do
    login(@project_editor)
    get :logo, params: { id: @project }
    assert_not_nil response
    assert_not_nil assigns(:project)
    assert_kind_of String, response.body
    assert_equal File.binread(File.join(CarrierWave::Uploader::Base.root, assigns(:project).logo.url)), response.body
  end

  test 'should not get logo as non-project user' do
    login(users(:two))
    get :logo, params: { id: @project }
    assert_redirected_to projects_path
  end

  test 'should get splash' do
    login(users(:valid))
    get :splash
    assert_not_nil assigns(:projects)
    assert_response :success
  end

  test 'should get paginated splash' do
    login(users(:valid))
    get :splash, format: 'js'
    assert_not_nil assigns(:projects)
    assert_template 'splash'
    assert_response :success
  end

  test 'should get splash and redirect to single project' do
    login(users(:site_one_viewer))
    get :splash
    assert_not_nil assigns(:projects)
    assert_equal 1, assigns(:projects).count
    assert_redirected_to projects(:one)
  end

  test 'should get splash and redirect to project invite' do
    login(users(:two))
    session[:invite_token] = project_users(:pending_editor_invite).invite_token
    get :splash
    assert_redirected_to accept_project_users_path
  end

  test 'should get splash and redirect to project site invite' do
    login(users(:two))
    session[:site_invite_token] = site_users(:invited).invite_token
    get :splash
    assert_redirected_to accept_project_site_users_path(@project)
  end

  test 'should get splash and remove invalid project site invite token' do
    login(users(:valid))
    session[:site_invite_token] = 'imaninvalidtoken'
    get :splash
    assert_nil session[:site_invite_token]
    assert_redirected_to root_path
  end

  test 'should get index' do
    login(users(:valid))
    get :index
    assert_response :success
    assert_not_nil assigns(:projects)
  end

  test 'should get paginated index' do
    login(users(:valid))
    get :index, format: 'js'
    assert_not_nil assigns(:projects)
    assert_template 'index'
  end

  test 'should get new' do
    login(users(:valid))
    get :new
    assert_response :success
  end

  test 'should create project' do
    login(users(:valid))
    assert_difference('Site.count') do
      assert_difference('Project.count') do
        post :create, params: {
          project: {
            name: 'Project New Name',
            description: @project.description,
            logo: fixture_file_upload('../../test/support/projects/rails.png')
          }
        }
      end
    end
    assert_not_nil assigns(:project)
    assert_equal(
      File.join(CarrierWave::Uploader::Base.root, 'projects', assigns(:project).id.to_s, 'logo', 'rails.png'),
      assigns(:project).logo.path
    )
    assert_equal 1, assigns(:project).sites.count
    assert_equal 'Default Site', assigns(:project).sites.first.name
    assert_redirected_to project_path(assigns(:project))
  end

  test 'should create project and automatically with a named site' do
    login(users(:valid))
    assert_difference('Site.count') do
      assert_difference('Project.count') do
        post :create, params: {
          project: {
            description: @project.description,
            name: 'Project New Name with Site',
            logo: fixture_file_upload('../../test/support/projects/rails.png'),
            site_name: 'New Site with Project'
          }
        }
      end
    end
    assert_not_nil assigns(:project)
    assert_equal(
      File.join(CarrierWave::Uploader::Base.root, 'projects', assigns(:project).id.to_s, 'logo', 'rails.png'),
      assigns(:project).logo.path
    )
    assert_equal 1, assigns(:project).sites.count
    assert_equal 'New Site with Project', assigns(:project).sites.first.name
    assert_redirected_to project_path(assigns(:project))
  end

  test 'should not create project with blank name' do
    login(users(:valid))
    assert_difference('Site.count', 0) do
      assert_difference('Project.count', 0) do
        post :create, params: {
          project: {
            description: @project.description,
            name: ''
          }
        }
      end
    end

    assert_not_nil assigns(:project)
    assert assigns(:project).errors.size > 0
    assert_equal ["can't be blank"], assigns(:project).errors[:name]
    assert_template 'new'
  end

  test 'should show project activity' do
    login(users(:valid))
    get :activity, params: { id: @project }
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test 'should show project' do
    login(users(:valid))
    get :show, params: { id: @project }
    assert_not_nil assigns(:project)
    assert_redirected_to project_subjects_path(assigns(:project))
  end

  test 'should show project using slug' do
    login(users(:valid))
    get :show, params: { id: projects(:named_project) }
    assert_not_nil assigns(:project)
    assert_redirected_to project_subjects_path(assigns(:project))
  end

  test 'should show project to site user' do
    login(users(:site_one_viewer))
    get :show, params: { id: @project }
    assert_not_nil assigns(:project)
    assert_redirected_to project_subjects_path(assigns(:project))
  end

  test 'should not show invalid project' do
    login(users(:valid))
    get :show, params: { id: -1 }
    assert_nil assigns(:project)
    assert_redirected_to projects_path
  end
end
