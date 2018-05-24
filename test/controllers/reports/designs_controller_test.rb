# frozen_string_literal: true

require "test_helper"

# Test to make sure basic and overview reports are viewable.
class Reports::DesignsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @viewer = users(:project_one_viewer)
    @project = projects(:one)
    @design = designs(:one)
  end

  test "should get basic as viewer" do
    login(@viewer)
    get project_reports_design_basic_url(@project, designs(:all_variable_types))
    assert_response :success
  end

  test "should show design overview as viewer" do
    login(@viewer)
    get project_reports_design_overview_url(@project, designs(:all_variable_types))
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should show design overview for design with sections as viewer" do
    login(@viewer)
    get project_reports_design_overview_url(@project, designs(:sections_and_variables))
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_response :success
  end
end
