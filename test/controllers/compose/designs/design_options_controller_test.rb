# frozen_string_literal: true

require "test_helper"

# Test editing design options while building a design.
class Compose::Designs::DesignOptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:one)
    @project_editor = users(:project_one_editor)
    @design = designs(:sections_and_variables)
    @design_option = design_options(:sections_and_variables_dropdown)
  end

  def design_option_params
    {
      branching_logic: "1 = 1",
      requirement: "required"
    }
  end

  test "should get show design option" do
    login(@project_editor)
    get compose_design_design_option_url(
      @project, @design, @design_option, format: "js"
    ), xhr: true
    assert_response :success
  end

  test "should get edit design option" do
    login(@project_editor)
    get edit_compose_design_design_option_url(
      @project, @design, @design_option, format: "js"
    ), xhr: true
    assert_response :success
  end

  test "should update design option" do
    login(@project_editor)
    patch compose_design_design_option_url(
      @project, @design, @design_option, format: "js"
    ), params: {
      design_option: design_option_params
    }
    assert_response :success
  end
end
