# frozen_string_literal: true

require "test_helper"

# Tests to make sure project and site members can export data.
class ExportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @regular_user = users(:regular)
    @no_export_user = users(:project_one_editor)
    @project = projects(:one)
    @export = exports(:one)
  end

  test "should get index" do
    login(@regular_user)
    get project_exports_url(@project)
    assert_response :success
  end

  test "should get index and redirect" do
    login(@no_export_user)
    get project_exports_url(@project)
    assert_redirected_to new_project_export_url(@project)
  end

  test "should get new" do
    login(@regular_user)
    get new_project_export_url(@project)
    assert_response :success
  end

  test "should create export with raw csv" do
    login(@regular_user)
    assert_difference("Export.count") do
      post project_exports_url(@project), params: {
        export: { include_csv_raw: "1" }
      }
    end
    assert_redirected_to [@project, Export.last]
  end

  test "should create export with labeled csv" do
    login(@regular_user)
    assert_difference("Export.count") do
      post project_exports_url(@project), params: {
        export: { include_csv_labeled: "1" }
      }
    end
    assert_redirected_to [@project, Export.last]
  end

  test "should create export with pdf collation" do
    login(@regular_user)
    assert_difference("Export.count") do
      post project_exports_url(@project), params: {
        export: { include_pdf: "1" }
      }
    end
    assert_redirected_to [@project, Export.last]
  end

  test "should create export with data dictionary" do
    login(@regular_user)
    assert_difference("Export.count") do
      post project_exports_url(@project), params: {
        export: { include_data_dictionary: "1" }
      }
    end
    assert_redirected_to [@project, Export.last]
  end

  test "should create export with medications" do
    login(users(:meds_project_editor))
    assert_difference("Export.count") do
      post project_exports_url(projects(:medications)), params: {
        export: { include_medications: "1" }
      }
    end
    assert_redirected_to [projects(:medications), Export.last]
  end

  test "should not create export without an option" do
    login(@regular_user)
    assert_difference("Export.count", 0) do
      post project_exports_url(@project), params: { export: { filters: "" } }
    end
    assert_equal ["must select at least one export option"], assigns(:export).errors[:export]
    assert_template "new"
  end

  test "should download export file" do
    login(@regular_user)
    assert_not_equal 0, @export.file.size
    get file_project_export_url(@project, @export)
    assert_equal File.binread(@export.file.path), response.body
  end

  test "should not download empty export file" do
    login(@regular_user)
    assert_equal 0, exports(:two).file.size
    get file_project_export_url(@project, exports(:two))
    assert_response :success
  end

  test "should not download export file as non user" do
    login(users(:site_one_viewer))
    assert_not_equal 0, @export.file.size
    get file_project_export_url(@project, @export)
    assert_redirected_to project_exports_url(@project)
  end

  test "should show export" do
    login(@regular_user)
    get project_export_url(@project, @export)
    assert_response :success
  end

  test "should not show invalid export" do
    login(@regular_user)
    get project_export_url(@project, -1)
    assert_redirected_to project_exports_url(@project)
  end

  test "should destroy export" do
    login(@regular_user)
    assert_difference("Export.current.count", -1) do
      delete project_export_url(@project, exports(:two))
    end
    assert_redirected_to project_exports_url(@project)
  end

  test "should not destroy invalid export" do
    login(@regular_user)
    assert_difference("Export.current.count", 0) do
      delete project_export_url(@project, -1)
    end
    assert_redirected_to project_exports_url(@project)
  end
end
