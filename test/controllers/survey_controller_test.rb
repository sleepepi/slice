require 'test_helper'

class SurveyControllerTest < ActionController::TestCase

  setup do
    @public_design = designs(:admin_public_design)
    @public_section = sections(:public)

    @private_design = designs(:sections_and_variables)
    @private_section = sections(:private)
  end

  test "should get survey with slug" do
    get :show, slug: @public_design.slug
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_equal true, assigns(:design).publicly_available
    assert_response :success
  end

  test "should not get private survey" do
    assert_equal false, @private_design.publicly_available
    get :show, slug: @private_design.slug
    assert_nil assigns(:project)
    assert_nil assigns(:design)
    assert_redirected_to about_survey_path
  end

  test "should get section image from public design without login" do
    get :section_image, slug: @public_design.slug, section_id: @public_section.id

    assert_not_nil response
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:section)

    assert_kind_of String, response.body
    assert_equal File.binread( File.join(CarrierWave::Uploader::Base.root, assigns(:section).image.url) ), response.body
  end

  test "should not get section image from private design without login" do
    get :section_image, slug: @private_design.slug, section_id: @private_section.id

    assert_nil assigns(:project)
    assert_nil assigns(:design)
    assert_nil assigns(:section)
    assert_redirected_to about_survey_path
  end

end
