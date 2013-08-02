require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
  end

  test "should get filters" do
    post :filters, id: @project, f: [{ id: variables(:dropdown).id, axis: 'row', missing: '0' }, { id: 'site', axis: 'col', missing: '0' }], format: 'js'
    assert_template 'filters'
    assert_response :success
  end

  test "should get new filter" do
    post :new_filter, id: @project, design_id: designs(:all_variable_types), f: [{ id: variables(:dropdown).id, axis: 'row', missing: '0' }, { id: 'site', axis: 'col', missing: '0' }], format: 'js'
    assert_template 'new_filter'
    assert_response :success
  end

  test "should edit filter" do
    post :edit_filter, id: @project, variable_id: variables(:dropdown).id, axis: 'row', missing: '0', format: 'js'
    assert_template 'edit_filter'
    assert_response :success
  end

  test "should get search" do
    get :search, q: ''

    assert_not_nil assigns(:subjects)
    assert_not_nil assigns(:projects)
    assert_not_nil assigns(:designs)
    assert_not_nil assigns(:variables)
    assert_not_nil assigns(:objects)

    assert_response :success
  end

  test "should get search and redirect" do
    get :search, q: 'Project With One Design'

    assert_not_nil assigns(:subjects)
    assert_not_nil assigns(:projects)
    assert_not_nil assigns(:designs)
    assert_not_nil assigns(:variables)
    assert_not_nil assigns(:objects)

    assert_equal 1, assigns(:objects).size

    assert_redirected_to assigns(:objects).first
  end

  test "should get search typeahead" do
    get :search, q: 'abc', format: 'json'

    assert_not_nil assigns(:subjects)
    assert_not_nil assigns(:projects)
    assert_not_nil assigns(:designs)
    assert_not_nil assigns(:variables)
    assert_not_nil assigns(:objects)

    assert_response :success
  end

  test "should get subject report" do
    get :subject_report, id: @project
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subjects)
    assert_not_nil assigns(:designs)
    assert_response :success
  end

  test "should not get subject report for invalid project" do
    get :subject_report, id: -1
    assert_nil assigns(:project)
    assert_redirected_to projects_path
  end

  test "should get splash" do
    get :splash
    assert_not_nil assigns(:projects)
    assert_response :success
  end

  test "should get paginated splash" do
    get :splash, format: 'js'
    assert_not_nil assigns(:projects)
    assert_template 'splash'
    assert_response :success
  end

  test "should get splash and redirect to single project" do
    login(users(:site_one_user))
    get :splash
    assert_not_nil assigns(:projects)
    assert_equal 1, assigns(:projects).count
    assert_redirected_to projects(:one)
  end

  test "should get report" do
    get :report, id: @project
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test "should get report before sheet date" do
    get :report, id: @project, sheet_before: "10/18/2012"
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test "should get report after sheet date" do
    get :report, id: @project, sheet_after: "10/01/2012"
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test "should get report between sheet date" do
    get :report, id: @project, sheet_after: "10/01/2012", sheet_before: "10/18/2012"
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test "should get report by week" do
    get :report, id: @project, by: 'week'
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test "should get report by year" do
    get :report, id: @project, by: 'year'
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test "should not get report for invalid project" do
    get :report, id: -1
    assert_nil assigns(:project)
    assert_redirected_to projects_path
  end

  test "should print report" do
    get :report_print, id: @project
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test "should not print invalid report" do
    get :report_print, id: -1
    assert_nil assigns(:project)
    assert_redirected_to projects_path
  end

  test "should remove attached file" do
    post :remove_file, id: @project, format: 'js'
    assert_not_nil assigns(:project)
    assert_template 'remove_file'
  end

  test "should not remove attached file" do
    login(users(:site_one_user))
    post :remove_file, id: @project, format: 'js'
    assert_nil assigns(:project)
    assert_response :success
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
    assert_difference('Site.count') do
      assert_difference('Project.count') do
        post :create, project: { description: @project.description, name: 'Project New Name', logo: fixture_file_upload('../../test/support/projects/rails.png') }
      end
    end

    assert_not_nil assigns(:project)
    assert_equal "#{Rails.root}/public/uploads/project/logo/#{assigns(:project).id}/rails.png", assigns(:project).logo.path
    assert_equal 1, assigns(:project).sites.count
    assert_equal "Default Site", assigns(:project).sites.first.name

    assert_redirected_to project_path(assigns(:project))
  end

  test "should create project and automatically with a named site" do
    assert_difference('Site.count') do
      assert_difference('Project.count') do
        post :create, project: { description: @project.description, name: 'Project New Name with Site', logo: fixture_file_upload('../../test/support/projects/rails.png'), site_name: 'New Site with Project' }
      end
    end

    assert_not_nil assigns(:project)
    assert_equal "#{Rails.root}/public/uploads/project/logo/#{assigns(:project).id}/rails.png", assigns(:project).logo.path
    assert_equal 1, assigns(:project).sites.count
    assert_equal "New Site with Project", assigns(:project).sites.first.name

    assert_redirected_to project_path(assigns(:project))
  end

  test "should not create project with blank name" do
    assert_difference('Site.count', 0) do
      assert_difference('Project.count', 0) do
        post :create, project: { description: @project.description, name: '' }
      end
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

  test "should show project to site user" do
    login(users(:site_one_user))
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
