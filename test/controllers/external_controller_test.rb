# frozen_string_literal: true

require 'test_helper'

# Tests to assure users can view section images and add grid rows on public
# surveys.
class ExternalControllerTest < ActionController::TestCase
  setup do
    @public_design = designs(:admin_public_design)
    @public_section = sections(:public)
    @private_design = designs(:sections_and_variables)
    @private_section = sections(:private)
  end

  test 'should get landing' do
    get :landing
    assert_response :success
  end

  test 'should add grid row as valid user' do
    login(users(:valid))
    post :add_grid_row, params: {
      design: designs(:has_grid), variable_id: variables(:grid),
      design_option_id: design_options(:has_grid_grid)
    }, format: 'js'
    assert_not_nil assigns(:variable)
    assert_template 'add_grid_row'
    assert_response :success
  end

  test 'should add grid row on public survey' do
    post :add_grid_row, params: {
      design: designs(:admin_public_design),
      variable_id: variables(:external_grid),
      design_option_id: design_options(:admin_public_design_external_grid),
      sheet_authentication_token: sheets(:external).authentication_token
    }, format: 'js'
    assert_not_nil assigns(:variable)
    assert_template 'add_grid_row'
    assert_response :success
  end

  test 'should add grid row for site editor' do
    login(users(:site_one_editor))
    post :add_grid_row, params: {
      design: designs(:has_grid), variable_id: variables(:grid),
      design_option_id: design_options(:has_grid_grid)
    }, format: 'js'
    assert_not_nil assigns(:variable)
    assert_template 'add_grid_row'
    assert_response :success
  end

  test 'should not add grid row for user not on project' do
    login(users(:two))
    post :add_grid_row, params: {
      design: designs(:has_grid), variable_id: variables(:grid),
      design_option_id: design_options(:has_grid_grid)
    }, format: 'js'
    assert_nil assigns(:variable)
    assert_response :success
  end

  test 'should add grid for handoff' do
    post :add_grid_row, params: {
      design: designs(:has_grid), variable_id: variables(:grid),
      design_option_id: design_options(:has_grid_grid), handoff: handoffs(:grid)
    }, format: 'js'
    assert_not_nil assigns(:variable)
    assert_template 'add_grid_row'
    assert_response :success
  end

  test 'should get section image from public design as public viewer' do
    get :section_image, params: {
      section_id: @public_section.id, design: @public_design
    }
    assert_not_nil response
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:section)
    assert_kind_of String, response.body
    assert_equal(
      File.binread(File.join(CarrierWave::Uploader::Base.root, assigns(:section).image.url)),
      response.body
    )
  end

  test 'should get section image from handoff' do
    @handoff = handoffs(:one)
    @design = designs(:sections_and_variables)
    @section = sections(:private)
    get :section_image, params: {
      section_id: @section.id, design: @design, handoff: @handoff
    }
    assert_not_nil response
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:section)
    assert_kind_of String, response.body
    assert_equal(
      File.binread(File.join(CarrierWave::Uploader::Base.root, assigns(:section).image.url)),
      response.body
    )
  end

  test 'should get section image from design as valid user' do
    login(users(:valid))
    get :section_image, params: {
      section_id: @private_section.id, design: @private_design
    }
    assert_not_nil response
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:section)
    assert_kind_of String, response.body
    assert_equal(
      File.binread(File.join(CarrierWave::Uploader::Base.root, assigns(:section).image.url)),
      response.body
    )
  end

  test 'should not get section image from private design without login' do
    get :section_image, params: {
      section_id: @private_section.id, design: @private_design
    }
    assert_nil assigns(:design)
    assert_nil assigns(:section)
    assert_response :success
  end
end
