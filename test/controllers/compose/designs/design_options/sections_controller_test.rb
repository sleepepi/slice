# frozen_string_literal: true

require "test_helper"

# Test editing sections while building a design.
class Compose::Designs::DesignOptions::SectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:one)
    @project_editor = users(:project_one_editor)
    @design = designs(:sections_and_variables)
    @design_option = design_options(:sections_and_variables_sectiona)
    @section = sections(:sectiona)
  end

  def section_params
    {
      name: "Section Name",
      description: "Section description.\nAnd more text.",
      level: "1"
    }
  end

  test "should get show section" do
    login(@project_editor)
    get compose_design_design_option_section_url(
      @project, @design, @design_option, @section, format: "js"
    ), xhr: true
    assert_response :success
  end

  test "should get edit section" do
    login(@project_editor)
    get edit_compose_design_design_option_section_url(
      @project, @design, @design_option, @section, format: "js"
    ), xhr: true
    assert_response :success
  end

  test "should update section" do
    login(@project_editor)
    patch compose_design_design_option_section_url(
      @project, @design, @design_option, @section, format: "js"
    ), params: {
      section: section_params
    }
    assert_response :success
  end
end
