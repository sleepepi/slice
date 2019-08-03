# frozen_string_literal: true

require "test_helper"

# Tests to make sure projects can be viewed and edited.
class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:one)
    @project_editor = users(:project_one_editor)
    @project_viewer = users(:project_one_viewer)
  end

  test "should save project order" do
    login(users(:regular))
    post save_project_order_projects_url(format: "js"), params: {
      project_ids: [
        ActiveRecord::FixtureSet.identify(:two),
        ActiveRecord::FixtureSet.identify(:one),
        ActiveRecord::FixtureSet.identify(:no_sites),
        ActiveRecord::FixtureSet.identify(:single_design),
        ActiveRecord::FixtureSet.identify(:empty),
        ActiveRecord::FixtureSet.identify(:named_project)
      ]
    }
    assert_response :success
  end

  test "should archive project" do
    login(users(:regular))
    assert_difference("ProjectPreference.where(archived: true).count") do
      post archive_project_url(@project)
    end
    assert_redirected_to root_path
  end

  test "should undo archive project" do
    login(users(:regular))
    assert_difference("ProjectPreference.where(archived: false).count") do
      post archive_project_url(projects(:two), undo: "1")
    end
    assert_redirected_to root_path
  end

  test "should get logo as project editor" do
    login(@project_editor)
    get logo_project_url(@project)
    assert_equal File.binread(assigns(:project).logo.path), response.body
  end

  test "should not get logo as non-project user" do
    login(users(:two))
    get logo_project_url(@project)
    assert_redirected_to projects_path
  end

  test "should get index" do
    login(users(:regular))
    get projects_url
    assert_response :success
  end

  test "should get index by reverse project name" do
    login(users(:regular))
    get projects_url, params: { order: "projects.name desc" }
    assert_response :success
  end

  test "should get new" do
    login(users(:regular))
    get new_project_url
    assert_response :success
  end

  test "should create project" do
    login(users(:regular))
    assert_difference("Site.count") do
      assert_difference("Project.count") do
        post projects_url, params: {
          project: {
            name: "Project New Name",
            description: @project.description,
            logo: fixture_file_upload(file_fixture("rails.png"))
          }
        }
      end
    end
    assert_equal(
      File.join(CarrierWave::Uploader::Base.root, "projects", assigns(:project).id.to_s, "logo", "rails.png"),
      assigns(:project).logo.path
    )
    assert_equal 1, assigns(:project).sites.count
    assert_equal "Default Site", assigns(:project).sites.first.name
    assert_equal "Default Site", assigns(:project).sites.first.short_name
    assert_redirected_to setup_project_sites_path(assigns(:project))
  end

  test "should not create project with blank name" do
    login(users(:regular))
    assert_difference("Site.count", 0) do
      assert_difference("Project.count", 0) do
        post projects_url, params: {
          project: {
            description: @project.description,
            name: ""
          }
        }
      end
    end
    assert_equal ["can't be blank"], assigns(:project).errors[:name]
    assert_template "new"
  end

  test "should show project activity" do
    login(users(:regular))
    get activity_project_url(@project)
    assert_response :success
  end

  test "should show project" do
    login(users(:regular))
    get project_url(@project)
    assert_response :success
  end

  test "should show project using slug" do
    login(users(:regular))
    get project_url(projects(:named_project))
    assert_response :success
  end

  test "should show project to site user" do
    login(users(:site_one_viewer))
    get project_url(@project)
    assert_response :success
  end

  test "should not show invalid project" do
    login(users(:regular))
    get project_url(-1)
    assert_redirected_to projects_path
  end

  test "should get calendar" do
    login(users(:regular))
    get calendar_project_url(@project)
    assert_response :success
  end

  test "should get reports as project editor" do
    login(@project_editor)
    get reports_project_url(@project)
    assert_response :success
  end

  test "should get reports as project viewer" do
    login(users(:project_one_viewer))
    get reports_project_url(@project)
    assert_response :success
  end

  test "should get expressions as project editor" do
    login(@project_editor)
    get expressions_project_url(@project)
    assert_response :success
  end

  test "should get expressions as project viewer" do
    login(users(:project_one_viewer))
    get expressions_project_url(@project)
    assert_response :success
  end
end

