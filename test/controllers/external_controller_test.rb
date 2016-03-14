# frozen_string_literal: true

require 'test_helper'

class ExternalControllerTest < ActionController::TestCase
  setup do
    @public_design = designs(:admin_public_design)
    @public_section = sections(:public)
    @private_design = designs(:sections_and_variables)
    @private_section = sections(:private)
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

  test 'should format number as valid user' do
    login(users(:valid))
    get :format_number, params: {
      design: designs(:all_variable_types), variable_id: variables(:calculated),
      calculated_number: '25.359'
    }, xhr: true, format: 'js'
    assert_not_nil assigns(:variable)
    assert_equal '25.36', assigns(:result)
    assert_template 'format_number'
  end

  test 'should format number if missing as valid user' do
    login(users(:valid))
    get :format_number, params: {
      design: designs(:all_variable_types), variable_id: variables(:calculated)
    }, xhr: true, format: 'js'
    assert_not_nil assigns(:variable)
    assert_equal nil, assigns(:result)
    assert_template 'format_number'
  end

  test 'should format number on variable with blank format' do
    login(users(:valid))
    get :format_number, params: {
      design: designs(:all_variable_types),
      variable_id: variables(:calculated_without_format),
      calculated_number: '25.359'
    }, xhr: true, format: 'js'
    assert_not_nil assigns(:variable)
    assert_equal '25.359', assigns(:result)
    assert_template 'format_number'
  end

  test 'should format number on public survey' do
    get :format_number, params: {
      design: designs(:admin_public_design),
      variable_id: variables(:external_calculated), calculated_number: '25.359'
    }, xhr: true, format: 'js'
    assert_not_nil assigns(:variable)
    assert_equal '25.36', assigns(:result)
    assert_template 'format_number'
  end

  test 'should not format number for user not on project' do
    login(users(:two))
    get :format_number, params: {
      design: designs(:all_variable_types),
      variable_id: variables(:calculated), calculated_number: '25.359'
    }, xhr: true, format: 'js'
    assert_nil assigns(:variable)
    assert_nil assigns(:result)
    assert_response :success
  end

  test 'should format number for handoff' do
    get :format_number, params: {
      design: designs(:all_variable_types), variable_id: variables(:calculated),
      handoff: handoffs(:calculated), calculated_number: '25.359'
    }, xhr: true, format: 'js'
    assert_not_nil assigns(:variable)
    assert_equal '25.36', assigns(:result)
    assert_template 'format_number'
  end

  test 'should get typeahead as valid user' do
    login(users(:valid))
    get :typeahead, params: {
      design: designs(:all_variable_types),
      variable_id: variables(:autocomplete)
    }, xhr: true, format: 'js'
    assert_not_nil assigns(:variable)
    assert_equal %w(Cat Dog Fish), assigns(:variable).autocomplete_array
    assert_response :success
  end

  test 'should not get typeahead for user not on project' do
    login(users(:two))
    get :typeahead, params: {
      design: designs(:all_variable_types),
      variable_id: variables(:autocomplete)
    }, xhr: true, format: 'js'
    assert_nil assigns(:variable)
    assert_response :success
  end

  test 'should get typeahead for public survey' do
    get :typeahead, params: {
      design: designs(:admin_public_design),
      variable_id: variables(:public_autocomplete)
    }, xhr: true, format: 'js'
    assert_not_nil assigns(:variable)
    assert_equal %w(Cat Dog Fish), assigns(:variable).autocomplete_array
    assert_response :success
  end

  test 'should get blank array for non-string typeahead' do
    login(users(:valid))
    get :typeahead, params: {
      design: designs(:all_variable_types), variable_id: variables(:dropdown)
    }, xhr: true, format: 'js'
    assert_not_nil assigns(:variable)
    assert_equal [], assigns(:variable).autocomplete_array
    assert_response :success
  end

  test 'should get typeahead for handoff' do
    get :typeahead, params: {
      design: designs(:all_variable_types),
      variable_id: variables(:autocomplete), handoff: handoffs(:typeahead)
    }, xhr: true, format: 'js'
    assert_not_nil assigns(:variable)
    assert_equal %w(Cat Dog Fish), assigns(:variable).autocomplete_array
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
