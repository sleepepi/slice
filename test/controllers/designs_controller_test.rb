# frozen_string_literal: true

require 'test_helper'

# Tests to assure that designs can be created and updated by project editors
class DesignsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @design = designs(:one)
  end

  test 'should show design overview' do
    get :overview, id: designs(:all_variable_types), project_id: @project
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should show design overview for design with variables using ajax' do
    xhr :get, :overview, id: designs(:all_variable_types), project_id: @project, format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_template 'overview'
  end

  test 'should show design overview for design with sections using ajax' do
    xhr :get, :overview, id: designs(:sections_and_variables), project_id: @project, format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_template 'overview'
  end

  test 'should print report' do
    get :report_print, id: @design, project_id: @project
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should not print invalid report' do
    get :report_print, id: -1, project_id: @project
    assert_not_nil assigns(:project)
    assert_nil assigns(:design)
    assert_redirected_to project_designs_path(assigns(:project))
  end

  test 'should get report' do
    get :report, id: @design, project_id: @project
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get report before sheet date' do
    get :report, id: @design, project_id: @project, sheet_before: '10/18/2012'
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get report after sheet date' do
    get :report, id: @design, project_id: @project, sheet_after: '10/01/2012'
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get report between sheet date' do
    get :report, id: @design, project_id: @project, sheet_after: '10/01/2012', sheet_before: '10/18/2012'
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get report by week' do
    get :report, id: @design, project_id: @project, by: 'week'
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get report by year' do
    get :report, id: @design, project_id: @project, by: 'year'
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get report with row variable (dropdown)' do
    get :report, id: @design, project_id: @project, f: [{ id: variables(:one).id, axis: 'row', missing: '1' }]
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get report with row variable (dropdown) and exclude missing' do
    get :report, id: @design, project_id: @project, f: [{ id: variables(:one).id, axis: 'row', missing: '0' }]
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get report with column variable (dropdown)' do
    get :report, id: @design, project_id: @project, f: [{ id: variables(:one).id, axis: 'col', missing: '1' }]
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get report string (row) by sheet date (col)' do
    get :report, id: @design, project_id: @project,
                 f: [
                   { id: variables(:string).id, axis: 'row', missing: '1' },
                   { id: 'sheet_date', axis: 'col', missing: '0' }
                 ]
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get report with column variable (date)' do
    get :report, id: @design, project_id: @project,
                 f: [{ id: variables(:date).id, axis: 'col', missing: '1' }]
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get report with column variable (numeric)' do
    get :report, id: designs(:all_variable_types), project_id: @project,
                 f: [{ id: variables(:numeric).id, axis: 'col', missing: '1' }]
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get report gender (row) by weight (column)' do
    get :report, id: designs(:weight_and_gender), project_id: @project,
                 f: [
                   { id: variables(:gender).id, axis: 'row', missing: '0' },
                   { id: variables(:weight).id, axis: 'col', missing: '0' }
                 ]
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get report weight (row) by site (column)' do
    get :report, id: designs(:weight_and_gender), project_id: @project,
                 f: [
                   { id: variables(:weight).id, axis: 'row', missing: '0' },
                   { id: 'site', axis: 'col', missing: '0' }
                 ]
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get report site and gender (row) by weight (column)' do
    get :report, id: designs(:weight_and_gender), project_id: @project,
                 f: [
                   { id: 'site', axis: 'row', missing: '0' },
                   { id: variables(:gender).id, axis: 'row', missing: '1' },
                   { id: variables(:weight).id, axis: 'col', missing: '1' }
                 ]
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get report as a CSV' do
    get :report, id: @design, project_id: @project, format: 'csv'
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should get report site and gender (row) by weight (column) as CSV' do
    get :report, id: designs(:weight_and_gender), project_id: @project,
                 f: [
                   { id: 'site', axis: 'row', missing: '0' },
                   { id: variables(:gender).id, axis: 'row', missing: '1' },
                   { id: variables(:weight).id, axis: 'col', missing: '1' }
                 ],
                 format: 'csv'
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should not get report for invalid design' do
    get :report, id: -1, project_id: @project
    assert_nil assigns(:design)
    assert_redirected_to project_designs_path(assigns(:project))
  end

  test 'should not get report with invalid project' do
    get :report, id: @design, project_id: -1
    assert_nil assigns(:project)
    assert_nil assigns(:design)
    assert_redirected_to root_path
  end

  test 'should get copy' do
    assert_difference('Design.count') do
      get :copy, id: @design, project_id: @project
    end

    assert_not_nil assigns(:design)
    assert_equal @design.name + ' Copy', assigns(:design).name
    assert_redirected_to edit_project_design_path(assigns(:design).project, assigns(:design))
  end

  test 'should not get copy for invalid design' do
    get :copy, id: -1, project_id: @project
    assert_nil assigns(:design)
    assert_redirected_to project_designs_path(assigns(:project))
  end

  test 'should not get copy for invalid project' do
    get :copy, id: @design, project_id: -1
    assert_nil assigns(:project)
    assert_nil assigns(:design)
    assert_redirected_to root_path
  end

  test 'should show design reorder mode' do
    get :reorder, id: @design, project_id: @project
    assert_template 'reorder'
    assert_response :success
  end

  test 'should get index' do
    get :index, project_id: @project
    assert_response :success
    assert_not_nil assigns(:designs)
  end

  test 'should not get index with invalid project' do
    get :index, project_id: -1
    assert_nil assigns(:designs)
    assert_redirected_to root_path
  end

  test 'should get index by user_name' do
    get :index, project_id: @project, order: 'designs.user_name'
    assert_not_nil assigns(:designs)
    assert_response :success
  end

  test 'should get paginated index by user_name desc' do
    get :index, project_id: @project, order: 'designs.user_name DESC'
    assert_not_nil assigns(:designs)
    assert_response :success
  end

  test 'should get new' do
    get :new, project_id: @project
    assert_response :success
  end

  test 'should create design' do
    assert_difference('Design.count') do
      post :create, project_id: @project, design: { name: 'Design Three' }, format: 'js'
    end

    assert_not_nil assigns(:design)
    assert_redirected_to edit_project_design_path(assigns(:design).project, assigns(:design))
  end

  test 'should create design with questions' do
    assert_difference('Variable.count', 3) do
      assert_difference('Design.count') do
        post :create, project_id: @project,
                      design: {
                        name: 'Design With Questions',
                        questions: [
                          { question_name: 'String Question', question_type: 'string' },
                          { question_name: 'Integer Question', question_type: 'integer' },
                          { question_name: 'Gender', question_type: 'radio' }
                        ]
                      }
      end
    end

    assert_not_nil assigns(:design)
    assert_redirected_to edit_project_design_path(assigns(:design).project, assigns(:design))
  end

  test 'should create design and save parseable redirect_url' do
    assert_difference('Design.count') do
      post :create, project_id: @project,
                    design: {
                      name: 'Public with Valid Redirect',
                      redirect_url: 'http://example.com'
                    },
                    format: 'js'
    end

    assert_not_nil assigns(:design)

    assert_equal 'http://example.com', assigns(:design).redirect_url

    assert_redirected_to edit_project_design_path(assigns(:design).project, assigns(:design))
  end

  test 'should create design but not save non http redirect_url' do
    assert_difference('Design.count') do
      post :create, project_id: @project,
                    design: {
                      name: 'Public with Invalid Redirect',
                      redirect_url: 'fake123'
                    },
                    format: 'js'
    end

    assert_not_nil assigns(:design)

    assert_equal '', assigns(:design).redirect_url

    assert_redirected_to edit_project_design_path(assigns(:design).project, assigns(:design))
  end

  test 'should create design but not save nonparseable redirect_url' do
    assert_difference('Design.count') do
      post :create, project_id: @project,
                    design: {
                      name: 'Public with Invalid Redirect',
                      redirect_url: 'fa\\ke'
                    },
                    format: 'js'
    end

    assert_not_nil assigns(:design)
    assert_equal '', assigns(:design).redirect_url

    assert_redirected_to edit_project_design_path(assigns(:design).project, assigns(:design))
  end

  test 'should not create design with invalid project' do
    assert_difference('Design.count', 0) do
      post :create, project_id: -1, design: { name: 'Design Three' }, format: 'js'
    end

    assert_nil assigns(:project)
    assert_nil assigns(:design)

    assert_response :success
  end

  # test 'should not create design with a duplicated variable' do
  #   assert_difference('Design.count', 0) do
  #     post :create, project_id: @project, design: { description: 'Design description', name: 'Design Three',
  #                             option_tokens: [ { 'variable_id' => ActiveRecord::FixtureSet.identify(:dropdown) },
  #                                              { 'variable_id' => ActiveRecord::FixtureSet.identify(:dropdown) }
  #                                            ]
  #                           }
  #   end

  #   assert_not_nil assigns(:design)
  #   assert_equal ['can only be added once'], assigns(:design).errors[:variables]
  #   assert_template 'new'
  # end

  # test 'should not create design with a duplicated section name' do
  #   assert_difference('Design.count', 0) do
  #     post :create, project_id: @project, design: { description: 'Design description', name: 'Design with Sections',
  #                             option_tokens: [ { 'section_name' => 'Section A' },
  #                                              { 'section_name' => 'Section A' }
  #                                            ]
  #                           }
  #   end

  #   assert_not_nil assigns(:design)
  #   assert_equal ['must be unique'], assigns(:design).errors[:section_names]
  #   assert_template 'new'
  # end

  test 'should show design' do
    get :show, id: @design, project_id: @project
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should show design as json' do
    get :show, id: @design, project_id: @project, format: 'json'
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should show design for project with no sites' do
    get :show, id: designs(:no_sites), project_id: projects(:no_sites)
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should not show invalid design' do
    get :show, id: -1, project_id: @project
    assert_not_nil assigns(:project)
    assert_nil assigns(:design)
    assert_redirected_to project_designs_path(assigns(:project))
  end

  test 'should not show design with invalid project' do
    get :show, id: @design, project_id: -1
    assert_nil assigns(:project)
    assert_nil assigns(:design)
    assert_redirected_to root_path
  end

  test 'should print design' do
    get :print, id: designs(:all_variable_types), project_id: @project
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should not print invalid design' do
    get :print, id: -1, project_id: @project
    assert_nil assigns(:design)
    assert_redirected_to project_designs_path(assigns(:project))
  end

  test 'should show design with all variable types' do
    get :show, id: designs(:all_variable_types), project_id: @project
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @design, project_id: @project
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test 'should not get edit for invalid design' do
    get :edit, id: -1, project_id: @project
    assert_not_nil assigns(:project)
    assert_nil assigns(:design)
    assert_redirected_to project_designs_path(assigns(:project))
  end

  test 'should not get edit with invalid project' do
    get :edit, id: @design, project_id: -1
    assert_nil assigns(:project)
    assert_nil assigns(:design)
    assert_redirected_to root_path
  end

  test 'should update design' do
    patch :update, id: @design, project_id: @project,
                   design: { description: 'Updated Description' },
                   format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_equal 'Updated Description', assigns(:design).description
    assert_template 'show'
  end

  test 'should update design and make publicly available' do
    patch :update, id: @design, project_id: @project,
                   design: { publicly_available: '1' },
                   format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_equal 'design-one', assigns(:design).slug
    assert_equal true, assigns(:design).publicly_available
    assert_template 'show'
  end

  test 'should update design and make custom slug' do
    patch :update, id: @design, project_id: @project,
                   design: { publicly_available: '1', slug: 'design-one-custom' },
                   format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_equal 'design-one-custom', assigns(:design).slug
    assert_equal true, assigns(:design).publicly_available
    assert_template 'show'
  end

  # test 'should not update design with blank name' do
  #   patch :update, id: @design, project_id: @project, design: { description: @design.description, name: '' }
  #   assert_not_nil assigns(:design)
  #   assert assigns(:design).errors.size > 0
  #   assert_equal ["can't be blank"], assigns(:design).errors[:name]
  #   assert_template 'edit'
  # end

  # test 'should not update invalid design' do
  #   patch :update, id: -1, project_id: @project, design: { description: @design.description, name: @design.name }
  #   assert_not_nil assigns(:project)
  #   assert_nil assigns(:design)
  #   assert_redirected_to project_designs_path(assigns(:project))
  # end

  # test 'should not update design with invalid project' do
  #   patch :update, id: @design, project_id: -1, design: { description: @design.description, name: @design.name }
  #   assert_nil assigns(:project)
  #   assert_nil assigns(:design)
  #   assert_redirected_to root_path
  # end

  test 'should destroy design' do
    assert_difference('Design.current.count', -1) do
      delete :destroy, id: @design, project_id: @project
    end

    assert_redirected_to project_designs_path(assigns(:project))
  end

  test 'should not destroy design with invalid project' do
    assert_difference('Design.current.count', 0) do
      delete :destroy, id: @design, project_id: -1
    end

    assert_nil assigns(:project)
    assert_nil assigns(:design)

    assert_redirected_to root_path
  end
end
