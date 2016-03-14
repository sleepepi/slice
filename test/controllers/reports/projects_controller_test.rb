# frozen_string_literal: true

require 'test_helper'

# Test that project and site members can view project reports
class Reports::ProjectsControllerTest < ActionController::TestCase
  setup do
    @project = projects(:one)
    @project_editor = users(:project_one_editor)
  end

  test 'should get filters' do
    login(users(:valid))
    post :filters, params: {
      id: @project,
      f: [
        { id: variables(:dropdown).id, axis: 'row', missing: '0' },
        { id: 'site', axis: 'col', missing: '0' }
      ]
    }, format: 'js'
    assert_template 'filters'
    assert_response :success
  end

  test 'should get new filter' do
    login(users(:valid))
    post :new_filter, params: {
      id: @project, design_id: designs(:all_variable_types),
      f: [
        { id: variables(:dropdown).id, axis: 'row', missing: '0' },
        { id: 'site', axis: 'col', missing: '0' }
      ]
    }, format: 'js'
    assert_template 'new_filter'
    assert_response :success
  end

  test 'should edit filter' do
    login(users(:valid))
    post :edit_filter, params: {
      id: @project, variable_id: variables(:dropdown).id, axis: 'row',
      missing: '0'
    }, format: 'js'
    assert_template 'edit_filter'
    assert_response :success
  end

  test 'should get reports as project editor' do
    login(@project_editor)
    get :reports, params: { id: @project }
    assert_response :success
  end

  test 'should get reports as project viewer' do
    login(users(:project_one_viewer))
    get :reports, params: { id: @project }
    assert_response :success
  end

  test 'should get report' do
    login(users(:valid))
    get :report, params: { id: @project }
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test 'should get report before sheet date' do
    login(users(:valid))
    get :report, params: { id: @project, sheet_before: '10/18/2012' }
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test 'should get report after sheet date' do
    login(users(:valid))
    get :report, params: { id: @project, sheet_after: '10/01/2012' }
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test 'should get report between sheet date' do
    login(users(:valid))
    get :report, params: { id: @project, sheet_after: '10/01/2012', sheet_before: '10/18/2012' }
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test 'should get report by week' do
    login(users(:valid))
    get :report, params: { id: @project, by: 'week' }
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test 'should get report by year' do
    login(users(:valid))
    get :report, params: { id: @project, by: 'year' }
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test 'should not get report for invalid project' do
    login(users(:valid))
    get :report, params: { id: -1 }
    assert_nil assigns(:project)
    assert_redirected_to projects_path
  end

  test 'should get report as a CSV' do
    login(users(:valid))
    get :report, params: { id: @project }, format: 'csv'
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test 'should print report' do
    skip if ENV['TRAVIS'] # Skip this test on Travis since Travis can't generate PDFs
    login(users(:valid))
    get :report, params: { id: @project }, format: 'pdf'
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test 'should not print invalid report' do
    skip if ENV['TRAVIS'] # Skip this test on Travis since Travis can't generate PDFs
    login(users(:valid))
    get :report, params: { id: -1 }, format: 'pdf'
    assert_nil assigns(:project)
    assert_redirected_to projects_path
  end

  test 'should show report if PDF fails to render' do
    skip if ENV['TRAVIS'] # Skip this test on Travis since Travis can't generate PDFs
    begin
      original_latex = ENV['latex_location']
      ENV['latex_location'] = "echo #{original_latex}"
      login(users(:valid))
      get :report, params: { id: projects(:two) }, format: 'pdf'
      assert_not_nil assigns(:project)
      assert_redirected_to report_reports_project_path(projects(:two))
    ensure
      ENV['latex_location'] = original_latex
    end
  end

  test 'should get subject report' do
    login(users(:valid))
    get :subject_report, params: { id: @project }
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subjects)
    assert_not_nil assigns(:designs)
    assert_response :success
  end

  test 'should not get subject report for invalid project' do
    login(users(:valid))
    get :subject_report, params: { id: -1 }
    assert_nil assigns(:project)
    assert_redirected_to projects_path
  end
end
