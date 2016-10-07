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
    assert_difference('ProjectPreference.where(favorited: true).count') do
      post :favorite, params: { id: @project, favorited: '1' }
    end
    assert_redirected_to root_path
  end

  test 'should get team as project editor' do
    login(@project_editor)
    get :team, params: { id: @project }
    assert_response :success
  end

  test 'should get team as project viewer' do
    login(@project_viewer)
    get :team, params: { id: @project }
    assert_response :success
  end

  test 'should archive project' do
    login(users(:valid))
    assert_difference('ProjectPreference.where(archived: true).count') do
      post :archive, params: { id: @project }
    end
    assert_redirected_to root_path
  end

  test 'should undo archive project' do
    login(users(:project_one_editor))
    assert_difference('ProjectPreference.where(archived: false).count') do
      post :archive, params: { id: @project, undo: '1' }
    end
    assert_redirected_to root_path
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

  test 'should get index' do
    login(users(:valid))
    get :index
    assert_not_nil assigns(:projects)
    assert_response :success
  end

  test 'should get index by reverse project name' do
    login(users(:valid))
    get :index, params: { order: 'projects.name desc' }
    assert_not_nil assigns(:projects)
    assert_response :success
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
    assert_redirected_to setup_project_sites_path(assigns(:project))
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
    assert_redirected_to setup_project_sites_path(assigns(:project))
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
    assert_response :success
  end

  test 'should show project using slug' do
    login(users(:valid))
    get :show, params: { id: projects(:named_project) }
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test 'should show project to site user' do
    login(users(:site_one_viewer))
    get :show, params: { id: @project }
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test 'should not show invalid project' do
    login(users(:valid))
    get :show, params: { id: -1 }
    assert_nil assigns(:project)
    assert_redirected_to projects_path
  end

  test 'should get calendar' do
    login(users(:valid))
    get :calendar, params: { id: @project }
    assert_response :success
  end
end
