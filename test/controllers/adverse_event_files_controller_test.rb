# frozen_string_literal: true

require "test_helper"

# Tests uploading files to adverse events.
class AdverseEventFilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project_editor = users(:regular)
    @site_editor = users(:site_one_editor)
    @site_viewer = users(:site_one_viewer)
    @project = projects(:one)
    @adverse_event = adverse_events(:one)
    @adverse_event_file = adverse_event_files(:one)
  end

  def adverse_event_file_params
    {
      attachment: fixture_file_upload(file_fixture("rails.png"))
    }
  end

  test "should get index as project editor" do
    login(@project_editor)
    get project_adverse_event_adverse_event_files_url(@project, @adverse_event)
    assert_response :success
  end

  test "should get index as site editor" do
    login(@site_editor)
    get project_adverse_event_adverse_event_files_url(@project, @adverse_event)
    assert_response :success
  end

  test "should get index as site viewer" do
    login(@site_viewer)
    get project_adverse_event_adverse_event_files_url(@project, @adverse_event)
    assert_response :success
  end

  test "should get new as project editor" do
    login(@project_editor)
    get new_project_adverse_event_adverse_event_file_url(@project, @adverse_event)
    assert_response :success
  end

  test "should get new as site editor" do
    login(@site_editor)
    get new_project_adverse_event_adverse_event_file_url(@project, @adverse_event)
    assert_response :success
  end

  test "should not get new as site viewer" do
    login(@site_viewer)
    get new_project_adverse_event_adverse_event_file_url(@project, @adverse_event)
    assert_redirected_to root_url
  end

  test "should create adverse event file as project editor" do
    login(@project_editor)
    assert_difference("AdverseEventFile.count") do
      post project_adverse_event_adverse_event_files_url(@project, @adverse_event), params: {
        adverse_event_file: adverse_event_file_params
      }
    end
    assert_redirected_to project_adverse_event_adverse_event_files_url(assigns(:project), assigns(:adverse_event))
  end

  test "should create adverse event file as site editor" do
    login(@site_editor)
    assert_difference("AdverseEventFile.count") do
      post project_adverse_event_adverse_event_files_url(@project, @adverse_event), params: {
        adverse_event_file: adverse_event_file_params
      }
    end
    assert_redirected_to project_adverse_event_adverse_event_files_url(assigns(:project), assigns(:adverse_event))
  end

  test "should not create adverse event file without file" do
    login(@project_editor)
    assert_difference("AdverseEventFile.count", 0) do
      post project_adverse_event_adverse_event_files_url(@project, @adverse_event), params: {
        adverse_event_file: adverse_event_file_params.merge(attachment: "")
      }
    end
    assert_equal ["can't be blank"], assigns(:adverse_event_file).errors[:attachment]
    assert_template "new"
    assert_response :success
  end

  test "should not create adverse event file as site viewer" do
    login(@site_viewer)
    assert_difference("AdverseEventFile.count", 0) do
      post project_adverse_event_adverse_event_files_url(@project, @adverse_event), params: {
        adverse_event_file: adverse_event_file_params
      }
    end
    assert_redirected_to root_url
  end

  test "should create multiple file attachments as project editor" do
    login(@project_editor)
    assert_difference("AdverseEventFile.count", 2) do
      post upload_project_adverse_event_adverse_event_files_url(
        @project, @adverse_event, format: "js"
      ), params: {
        attachments: [
          fixture_file_upload(file_fixture("rails.png")),
          fixture_file_upload(file_fixture("rails.png"))
        ]
      }
    end
    assert_template "index"
    assert_response :success
  end

  test "should get show as project editor" do
    login(@project_editor)
    get project_adverse_event_adverse_event_file_url(@project, @adverse_event, @adverse_event_file)
    assert_response :success
  end

  test "should get show as site editor" do
    login(@site_editor)
    get project_adverse_event_adverse_event_file_url(@project, @adverse_event, @adverse_event_file)
    assert_response :success
  end

  test "should get show as site viewer" do
    login(@site_viewer)
    get project_adverse_event_adverse_event_file_url(@project, @adverse_event, @adverse_event_file)
    assert_response :success
  end

  test "should download image as project editor" do
    login(@project_editor)
    get download_project_adverse_event_adverse_event_file_url(@project, @adverse_event, @adverse_event_file)
    assert_equal File.binread(assigns(:adverse_event_file).attachment.path), response.body
    assert_response :success
  end

  test "should download pdf as project editor" do
    login(@project_editor)
    get download_project_adverse_event_adverse_event_file_url(@project, @adverse_event, adverse_event_files(:two))
    assert_equal File.binread(assigns(:adverse_event_file).attachment.path), response.body
    assert_response :success
  end

  test "should destroy adverse event file as project editor" do
    login(@project_editor)
    assert_difference("AdverseEventFile.count", -1) do
      delete project_adverse_event_adverse_event_file_url(@project, @adverse_event, adverse_event_files(:delete_me))
    end
    assert_redirected_to project_adverse_event_adverse_event_files_url(assigns(:project), assigns(:adverse_event))
  end

  test "should destroy adverse event file as site editor" do
    login(@site_editor)
    assert_difference("AdverseEventFile.count", -1) do
      delete project_adverse_event_adverse_event_file_url(@project, @adverse_event, adverse_event_files(:delete_me))
    end
    assert_redirected_to project_adverse_event_adverse_event_files_url(assigns(:project), assigns(:adverse_event))
  end

  test "should not destroy adverse event file as site viewer" do
    login(@site_viewer)
    assert_difference("AdverseEventFile.count", 0) do
      delete project_adverse_event_adverse_event_file_url(@project, @adverse_event, adverse_event_files(:delete_me))
    end
    assert_redirected_to root_url
  end
end
