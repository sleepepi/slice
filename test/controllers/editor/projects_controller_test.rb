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
      randomizations_enabled: "1",
      adverse_events_enabled: "1",
      blinding_enabled: "1",
      handoffs_enabled: "1",
      auto_lock_sheets: "after24hours"
    }
  end

  test "should get advanced" do
    login(@unblinded_editor)
    get advanced_editor_project_url(@project)
    assert_response :success
  end

  test "should get invite" do
    login(@unblinded_editor)
    get invite_editor_project_url(@project)
    assert_response :success
  end

  test "should add invite row" do
    login(@unblinded_editor)
    post add_invite_row_editor_project_url(@project, format: "js")
    assert_template "add_invite_row"
    assert_response :success
  end

  test "should send invites" do
    login(@unblinded_editor)
    assert_difference("ActionMailer::Base.deliveries.size", 2) do
      post send_invites_editor_project_url(@project, format: "js"), params: {
        invites: [
          { email: "tom@example.com", site_id: "", editor: "1", unblinded: "1" },
          { email: "blinded@example.com", site_id: "", editor: "0", unblinded: "0" }
        ]
      }
    end
    assert_redirected_to settings_editor_project_path(@project)
  end

  test "should create project user" do
    login(@unblinded_editor)
    assert_difference("ProjectUser.count") do
      post invite_user_editor_project_url(@project, format: "js"), params: {
        editor: "1",
        invite_email: "#{users(:two).full_name} [#{users(:two).email}]"
      }
    end
    assert_template "invite_user"
    assert_response :success
  end

  test "should only create blinded members as blinded project user" do
    login(users(:project_one_editor_blinded))
    assert_difference("ProjectUser.count") do
      post invite_user_editor_project_url(@project, format: "js"), params: {
        editor: "1",
        invite_email: "#{users(:two).full_name} [#{users(:two).email}]",
        unblinded: "1"
      }
    end
    assert_equal false, assigns(:member).unblinded?
    assert_template "invite_user"
    assert_response :success
  end

  test "should create project user and automatically add associated user" do
    login(users(:regular))
    assert_difference("ProjectUser.count") do
      post invite_user_editor_project_url(projects(:single_design), format: "js"), params: {
        editor: "1",
        invite_email: "#{users(:associated).full_name} [#{users(:associated).email}]"
      }
    end
    assert_template "invite_user"
    assert_response :success
  end

  test "should create project user invitation" do
    login(@unblinded_editor)
    assert_difference("ProjectUser.count") do
      post invite_user_editor_project_url(@project, format: "js"), params: {
        editor: "1",
        invite_email: "invite@example.com"
      }
    end
    assert_not_nil assigns(:member).invite_token
    assert_template "invite_user"
    assert_response :success
  end

  test "should not create project user with invalid project id" do
    login(@unblinded_editor)
    assert_difference("ProjectUser.count", 0) do
      post invite_user_editor_project_url(-1, format: "js"), params: {
        editor: "1",
        invite_email: "#{users(:two).full_name} [#{users(:two).email}]"
      }
    end
    assert_response :success
  end

  test "should create site editor as editor" do
    login(@unblinded_editor)
    assert_difference("SiteUser.count") do
      post invite_user_editor_project_url(@project, format: "js"), params: {
        site_id: sites(:one).id,
        editor: "1",
        invite_email: "invite@example.com"
      }
    end
    assert_equal true, assigns(:member).editor
    assert_template "invite_user"
    assert_response :success
  end

  test "should create site viewer as editor" do
    login(@unblinded_editor)
    assert_difference("SiteUser.count") do
      post invite_user_editor_project_url(@project, format: "js"), params: {
        site_id: sites(:one).id,
        invite_email: "invite@example.com"
      }
    end
    assert_equal false, assigns(:member).editor
    assert_template "invite_user"
    assert_response :success
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
    assert_equal true, assigns(:project).randomizations_enabled?
    assert_equal true, assigns(:project).adverse_events_enabled?
    assert_equal true, assigns(:project).blinding_enabled?
    assert_equal true, assigns(:project).handoffs_enabled?
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

  test "should not update project blinding as blinded editor" do
    login(@blinded_editor)
    patch editor_project_url(@project), params: { project: project_params.merge(blinding_enabled: "0") }
    assert_equal true, assigns(:project).blinding_enabled?
    assert_redirected_to settings_editor_project_path(assigns(:project))
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
      FileUtils.cp File.join("test", "support", "projects", "rails.png"),
                   File.join("test", "support", "projects", "980190962", "logo", "rails.png")
    end
  end

  test "should not remove attached logo as site viewer" do
    assert_not_equal 0, @project.logo.size
    login(users(:site_one_viewer))
    patch editor_project_url(@project), params: { project: { remove_logo: "1" } }
    assert_not_equal 0, @project.logo.size
    assert_redirected_to projects_path
  end
end
