# frozen_string_literal: true

require "test_helper"

# Tests to assure that project editors can modify projects.
class Editor::ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:one)
    @unblinded_editor = users(:project_one_editor)
    @blinded_editor = users(:project_one_editor_blinded)
  end

  def project_params
    {
      name: "My Project",
      slug: "my-project",
      description: "Project Description\n Line two",
      disable_all_emails: "1",
      hide_values_on_pdfs: "1",
      adverse_events_enabled: "1",
      auto_lock_sheets: "after24hours"
    }
  end

  test "should get settings as owner" do
    login(users(:regular))
    get settings_editor_project_url(@project)
    assert_response :success
  end

  test "should get settings as editor" do
    login(@unblinded_editor)
    get settings_editor_project_url(@project)
    assert_response :success
  end

  test "should get edit" do
    login(@unblinded_editor)
    get edit_editor_project_url(@project)
    assert_response :success
  end

  test "should update project" do
    login(@unblinded_editor)
    patch editor_project_url(@project), params: { project: project_params }
    assert_equal "My Project", assigns(:project).name
    assert_equal "my-project", assigns(:project).slug
    assert_equal "Project Description\n Line two", assigns(:project).description
    assert_equal true, assigns(:project).disable_all_emails?
    assert_equal true, assigns(:project).hide_values_on_pdfs?
    assert_equal true, assigns(:project).adverse_events_enabled?
    assert_equal "after24hours", assigns(:project).auto_lock_sheets
    assert_redirected_to settings_editor_project_path(assigns(:project))
  end

  test "should not update project with blank name" do
    login(@unblinded_editor)
    patch editor_project_url(@project), params: { project: { name: "" } }
    assert_equal ["can't be blank"], assigns(:project).errors[:name]
    assert_template "edit"
    assert_response :success
  end

  test "should not update invalid project" do
    login(@unblinded_editor)
    patch editor_project_url(-1), params: { project: { name: @project.name, description: @project.description } }
    assert_redirected_to projects_path
  end

  test "should remove attached logo" do
    login(@unblinded_editor)
    begin
      assert_not_equal 0, @project.logo.size
      patch editor_project_url(@project), params: { project: { remove_logo: "1" } }
      assert_equal 0, assigns(:project).logo.size
      assert_redirected_to settings_editor_project_path(@project)
    ensure
      # Reset File after test run
      FileUtils.cp file_fixture("rails.png"), # File.join("test", "fixtures", "files", "rails.png"),
                   File.join(CarrierWave::Uploader::Base.root, "projects", "980190962", "logo", "rails.png")
    end
  end

  test "should not remove attached logo as site viewer" do
    assert_not_equal 0, @project.logo.size
    login(users(:site_one_viewer))
    patch editor_project_url(@project), params: { project: { remove_logo: "1" } }
    assert_not_equal 0, @project.logo.size
    assert_redirected_to projects_path
  end

  test "should toggle project blinding" do
    login(users(:regular))
    patch toggle_editor_project_url(projects(:default), feature: "blinding", enabled: "1", format: "js")
    projects(:default).reload
    assert_equal true, projects(:default).blinding_enabled?
    assert_response :success
  end

  test "should not toggle project blinding as blinded editor" do
    login(@blinded_editor)
    patch toggle_editor_project_url(projects(:one), feature: "blinding", enabled: "0", format: "js")
    projects(:one).reload
    assert_equal true, projects(:one).blinding_enabled?
    assert_response :success
  end

  test "should toggle project handoffs" do
    login(users(:regular))
    patch toggle_editor_project_url(projects(:default), feature: "handoffs", enabled: "1", format: "js")
    projects(:default).reload
    assert_equal true, projects(:default).handoffs_enabled?
    assert_response :success
  end

  test "should toggle project medications" do
    login(users(:regular))
    patch toggle_editor_project_url(projects(:default), feature: "medications", enabled: "1", format: "js")
    projects(:default).reload
    assert_equal true, projects(:default).medications_enabled?
    assert_response :success
  end

  test "should toggle project randomizations" do
    login(users(:regular))
    patch toggle_editor_project_url(projects(:default), feature: "randomizations", enabled: "1", format: "js")
    projects(:default).reload
    assert_equal true, projects(:default).randomizations_enabled?
    assert_response :success
  end

  test "should toggle project translations" do
    login(users(:regular))
    patch toggle_editor_project_url(projects(:default), feature: "translations", enabled: "1", format: "js")
    projects(:default).reload
    assert_equal true, projects(:default).translations_enabled?
    assert_response :success
  end
end
