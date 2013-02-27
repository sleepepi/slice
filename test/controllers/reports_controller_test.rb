require 'test_helper'

class ReportsControllerTest < ActionController::TestCase

  setup do
    login(users(:valid))
    @report = reports(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should create report" do
    assert_difference('Report.count') do
      post :create, report: { name: 'New Report', options: { design_id: designs(:one).id, by: 'month', percent: 'none', filter: 'all', sheet_after: '', sheet_before: '', variable_id: '', include_missing: '1', column_variable_id: '', column_include_missing: '1' } }, format: 'js'
    end

    assert_template 'create'
    assert_response :success
  end

  test "should not create report with blank name" do
    assert_difference('Report.count', 0) do
      post :create, report: { name: '', options: { design_id: designs(:one).id, by: 'month', percent: 'none', filter: 'all', sheet_after: '', sheet_before: '', variable_id: '', include_missing: '1', column_variable_id: '', column_include_missing: '1' } }, format: 'js'
    end

    assert_template 'create'
    assert_response :success
  end

  test "should show report" do
    get :show, id: @report
    assert_not_nil assigns(:report)
    assert_not_nil assigns(:design)
    assert_redirected_to report_project_design_path(designs(:one).project, designs(:one), @report.options.except(:design_id))
  end

  test "should not show report without design" do
    get :show, id: reports(:no_design)
    assert_not_nil assigns(:report)
    assert_nil assigns(:design)
    assert_redirected_to reports_path
  end

  test "should destroy report" do
    assert_difference('Report.current.count', -1) do
      delete :destroy, id: @report, format: 'js'
    end

    assert_template 'destroy'
    assert_response :success
  end

end
