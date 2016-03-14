# frozen_string_literal: true

require 'test_helper'

# Test to make sure basic, advanced, and overview reports generate correctly as
# well as their CSV and PDF versions.
class Reports::DesignsControllerTest < ActionController::TestCase
  setup do
    @viewer = users(:project_one_viewer)
    @project = projects(:one)
    @design = designs(:one)
  end

  test 'should show design overview as viewer' do
    login(@viewer)
    get :overview, params: { project_id: @project, id: designs(:all_variable_types) }
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should show design overview for design with sections as viewer' do
    login(@viewer)
    get :overview, params: { project_id: @project, id: designs(:sections_and_variables) }
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_response :success
  end

  # test 'should get basic as viewer' do
  #   login(@viewer)
  #   get :basic
  #   assert_response :success
  # end

  test 'should get advanced report as viewer' do
    login(@viewer)
    get :advanced, params: { project_id: @project, id: @design }
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get advanced report before sheet date as viewer' do
    login(@viewer)
    get :advanced, params: { project_id: @project, id: @design, sheet_before: '10/18/2012' }
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get advanced report after sheet date as viewer' do
    login(@viewer)
    get :advanced, params: { project_id: @project, id: @design, sheet_after: '10/01/2012' }
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get advanced report between sheet date as viewer' do
    login(@viewer)
    get :advanced, params: { project_id: @project, id: @design, sheet_after: '10/01/2012', sheet_before: '10/18/2012' }
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get advanced report by week as viewer' do
    login(@viewer)
    get :advanced, params: { project_id: @project, id: @design, by: 'week' }
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get advanced report by year as viewer' do
    login(@viewer)
    get :advanced, params: { project_id: @project, id: @design, by: 'year' }
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get advanced report with row variable (dropdown) as viewer' do
    login(@viewer)
    get :advanced, params: { project_id: @project, id: @design, f: [{ id: variables(:one).id, axis: 'row', missing: '1' }] }
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get advanced report with row variable (dropdown) and exclude missing as viewer' do
    login(@viewer)
    get :advanced, params: { project_id: @project, id: @design, f: [{ id: variables(:one).id, axis: 'row', missing: '0' }] }
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get advanced report with column variable (dropdown) as viewer' do
    login(@viewer)
    get :advanced, params: { project_id: @project, id: @design, f: [{ id: variables(:one).id, axis: 'col', missing: '1' }] }
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get advanced report string (row) by sheet date (col) as viewer' do
    login(@viewer)
    get :advanced, params: {
      project_id: @project, id: @design,
      f: [
        { id: variables(:string).id, axis: 'row', missing: '1' },
        { id: 'sheet_date', axis: 'col', missing: '0' }
      ]
    }
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get advanced report with column variable (date) as viewer' do
    login(@viewer)
    get :advanced, params: {
      project_id: @project, id: @design,
      f: [{ id: variables(:date).id, axis: 'col', missing: '1' }]
    }
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get advanced report with column variable (numeric) as viewer' do
    login(@viewer)
    get :advanced, params: {
      project_id: @project, id: designs(:all_variable_types),
      f: [{ id: variables(:numeric).id, axis: 'col', missing: '1' }]
    }
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get advanced report gender (row) by weight (column) as viewer' do
    login(@viewer)
    get :advanced, params: {
      project_id: @project, id: designs(:weight_and_gender),
      f: [
        { id: variables(:gender).id, axis: 'row', missing: '0' },
        { id: variables(:weight).id, axis: 'col', missing: '0' }
      ]
    }
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get advanced report weight (row) by site (column) as viewer' do
    login(@viewer)
    get :advanced, params: {
      project_id: @project, id: designs(:weight_and_gender),
      f: [
        { id: variables(:weight).id, axis: 'row', missing: '0' },
        { id: 'site', axis: 'col', missing: '0' }
      ]
    }
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get advanced report site and gender (row) by weight (column) as viewer' do
    login(@viewer)
    get :advanced, params: {
      project_id: @project, id: designs(:weight_and_gender),
      f: [
        { id: 'site', axis: 'row', missing: '0' },
        { id: variables(:gender).id, axis: 'row', missing: '1' },
        { id: variables(:weight).id, axis: 'col', missing: '1' }
      ]
    }
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get advanced report as a CSV as viewer' do
    login(@viewer)
    get :advanced, params: { project_id: @project, id: @design }, format: 'csv'
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get advanced report site and gender (row) by weight (column) as CSV as viewer' do
    login(@viewer)
    get :advanced, params: {
      project_id: @project, id: designs(:weight_and_gender),
      f: [
        { id: 'site', axis: 'row', missing: '0' },
        { id: variables(:gender).id, axis: 'row', missing: '1' },
        { id: variables(:weight).id, axis: 'col', missing: '1' }
      ]
    }, format: 'csv'
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should not get report for invalid design as viewer' do
    login(@viewer)
    get :advanced, params: { project_id: @project, id: -1 }
    assert_nil assigns(:design)
    assert_redirected_to project_designs_path(assigns(:project))
  end

  test 'should not get report with invalid project as viewer' do
    login(@viewer)
    get :advanced, params: { project_id: -1, id: @design }
    assert_nil assigns(:project)
    assert_nil assigns(:design)
    assert_redirected_to root_path
  end

  test 'should print advanced report as viewer' do
    skip if ENV['TRAVIS'] # Skip this test on Travis since Travis can't generate PDFs
    login(@viewer)
    get :advanced, params: { project_id: @project, id: @design }, format: 'pdf'
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should not print invalid advanced report as viewer' do
    skip if ENV['TRAVIS'] # Skip this test on Travis since Travis can't generate PDFs
    login(@viewer)
    get :advanced, params: { project_id: @project, id: -1 }, format: 'pdf'
    assert_not_nil assigns(:project)
    assert_nil assigns(:design)
    assert_redirected_to project_designs_path(assigns(:project))
  end

  test 'should show advanced report if PDF fails to render as viewer' do
    skip if ENV['TRAVIS'] # Skip this test on Travis since Travis can't generate PDFs
    begin
      original_latex = ENV['latex_location']
      ENV['latex_location'] = "echo #{original_latex}"
      login(@viewer)
      get :advanced, params: { project_id: @project, id: designs(:has_no_validations) }, format: 'pdf'
      assert_not_nil assigns(:project)
      assert_not_nil assigns(:design)
      assert_redirected_to project_reports_design_advanced_path(@project, designs(:has_no_validations))
    ensure
      ENV['latex_location'] = original_latex
    end
  end
end
