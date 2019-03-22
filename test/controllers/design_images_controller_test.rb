# frozen_string_literal: true

require "test_helper"

# Displays images attached to designs.
class DesignImagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:one)
    @design = designs(:sections_and_variables)
    @image = design_images(:sections_and_variables_one)
  end

  test "should show design image" do
    get design_image_url(@project, @design, @image)
    assert_response :success
  end
end
