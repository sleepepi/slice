require 'test_helper'

class DesignsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @design = designs(:one)
  end

  test "should print report" do
    get :report_print, id: @design, project_id: @project
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should not print invalid report" do
    get :report_print, id: -1, project_id: @project
    assert_not_nil assigns(:project)
    assert_nil assigns(:design)
    assert_redirected_to project_designs_path(assigns(:project))
  end

  test "should get report" do
    get :report, id: @design, project_id: @project
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should get report before sheet date" do
    get :report, id: @design, project_id: @project, sheet_before: "10/18/2012"
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should get report after sheet date" do
    get :report, id: @design, project_id: @project, sheet_after: "10/01/2012"
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should get report between sheet date" do
    get :report, id: @design, project_id: @project, sheet_after: "10/01/2012", sheet_before: "10/18/2012"
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should get report by week" do
    get :report, id: @design, project_id: @project, by: 'week'
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should get report by year" do
    get :report, id: @design, project_id: @project, by: 'year'
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should get report with row variable (dropdown)" do
    get :report, id: @design, project_id: @project, variable_id: variables(:one), include_missing: '1'
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should get report with column variable (dropdown)" do
    get :report, id: @design, project_id: @project, column_variable_id: variables(:one), column_include_missing: '1'
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should get report with column variable (date)" do
    get :report, id: @design, project_id: @project, column_variable_id: variables(:date), column_include_missing: '1'
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should get report with column variable (numeric)" do
    get :report, id: designs(:all_variable_types), project_id: @project, column_variable_id: variables(:numeric), column_include_missing: '1'
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should get report with column variable (numeric) and last sheet only" do
    get :report, id: designs(:all_variable_types), project_id: @project, column_variable_id: variables(:numeric), column_include_missing: '1', filter: 'last'
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should get report as a CSV" do
    get :report, id: @design, project_id: @project, format: 'csv'
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should not get report for invalid design" do
    get :report, id: -1, project_id: @project
    assert_nil assigns(:design)
    assert_redirected_to project_designs_path(assigns(:project))
  end

  test "should not get report with invalid project" do
    get :report, id: @design, project_id: -1
    assert_nil assigns(:project)
    assert_nil assigns(:design)
    assert_redirected_to root_path
  end

  test "should get copy" do
    get :copy, id: @design, project_id: @project
    assert_not_nil assigns(:design)
    assert_template 'new'
    assert_response :success
  end

  test "should not get copy for invalid design" do
    get :copy, id: -1, project_id: @project
    assert_nil assigns(:design)
    assert_redirected_to project_designs_path(assigns(:project))
  end

  test "should not get copy for invalid project" do
    get :copy, id: @design, project_id: -1
    assert_nil assigns(:project)
    assert_nil assigns(:design)
    assert_redirected_to root_path
  end

  test "should reorder variables" do
    post :reorder, id: @design, project_id: @project, rows: "option_1,option_0,option_2", format: 'js'
    assert_not_nil assigns(:design)
    assert_equal [ActiveRecord::Fixtures.identify(:two), ActiveRecord::Fixtures.identify(:one), ActiveRecord::Fixtures.identify(:date)], assigns(:design).options.collect{|option| option[:variable_id]}
    assert_template 'reorder'
  end

  test "should reorder sections" do
    post :reorder, id: designs(:sections_and_variables), project_id: @project, sections: "section_1,section_0", format: 'js'
    assert_not_nil assigns(:design)
    assert_equal [
                    ActiveRecord::Fixtures.identify(:date),
                    'Section B',
                    ActiveRecord::Fixtures.identify(:string),
                    ActiveRecord::Fixtures.identify(:text),
                    ActiveRecord::Fixtures.identify(:integer),
                    ActiveRecord::Fixtures.identify(:numeric),
                    ActiveRecord::Fixtures.identify(:file),
                    'Section A',
                    ActiveRecord::Fixtures.identify(:dropdown),
                    ActiveRecord::Fixtures.identify(:checkbox),
                    ActiveRecord::Fixtures.identify(:radio)
                 ], assigns(:design).options.collect{|option| option[:variable_id].blank? ? option[:section_name] : option[:variable_id]}
    assert_template 'reorder'
  end

  test "should reorder sections (keep same order)" do
    post :reorder, id: designs(:sections_and_variables), project_id: @project, sections: "section_0,section_1", format: 'js'
    assert_not_nil assigns(:design)

    assert_equal [
                    ActiveRecord::Fixtures.identify(:date),
                    'Section A',
                    ActiveRecord::Fixtures.identify(:dropdown),
                    ActiveRecord::Fixtures.identify(:checkbox),
                    ActiveRecord::Fixtures.identify(:radio),
                    'Section B',
                    ActiveRecord::Fixtures.identify(:string),
                    ActiveRecord::Fixtures.identify(:text),
                    ActiveRecord::Fixtures.identify(:integer),
                    ActiveRecord::Fixtures.identify(:numeric),
                    ActiveRecord::Fixtures.identify(:file)
                 ], assigns(:design).options.collect{|option| option[:variable_id].blank? ? option[:section_name] : option[:variable_id]}
    assert_template 'reorder'
  end

  test "should not reorder sections with different section count" do
    post :reorder, id: designs(:sections_and_variables), project_id: @project, sections: "section_1", format: 'js'
    assert_not_nil assigns(:design)
    assert_equal [
                ActiveRecord::Fixtures.identify(:date),
                'Section A',
                ActiveRecord::Fixtures.identify(:dropdown),
                ActiveRecord::Fixtures.identify(:checkbox),
                ActiveRecord::Fixtures.identify(:radio),
                'Section B',
                ActiveRecord::Fixtures.identify(:string),
                ActiveRecord::Fixtures.identify(:text),
                ActiveRecord::Fixtures.identify(:integer),
                ActiveRecord::Fixtures.identify(:numeric),
                ActiveRecord::Fixtures.identify(:file)
             ], assigns(:design).options.collect{|option| option[:variable_id].blank? ? option[:section_name] : option[:variable_id]}
    assert_template 'reorder'
  end

  test "should not reorder for invalid design" do
    login(users(:site_one_user))
    post :reorder, id: designs(:sections_and_variables), project_id: @project, sections: "section_0,section_1", format: 'js'
    assert_nil assigns(:design)
    assert_response :success
  end

  test "should get batch" do
    get :batch, project_id: @project
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:designs)
    assert_not_nil assigns(:sites)
    assert_not_nil assigns(:emails)
    assert_response :success
  end

  test "should not get batch with invalid project" do
    get :batch, project_id: -1
    assert_nil assigns(:project)
    assert_nil assigns(:designs)
    assert_nil assigns(:sites)
    assert_nil assigns(:emails)
    assert_redirected_to root_path
  end

  test "should create batch" do
    assert_difference('Sheet.count', 2) do
      assert_difference('Subject.count', 2) do
        post :create_batch, project_id: @project, design_id: @design, site_id: sites(:one), emails: 'S100 <one@example.com>; S200 <two@example.com>'
      end
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:site)
    assert_not_nil assigns(:emails)
    assert_redirected_to project_sheets_path(assigns(:project), site_id: assigns(:site).id, design_id: assigns(:design).id, user_id: users(:valid).id)
  end

  test "should not create batch with missing design" do
    assert_difference('Sheet.count', 0) do
      assert_difference('Subject.count', 0) do
        post :create_batch, project_id: @project, design_id: -1, site_id: sites(:one), emails: 'S100 <one@example.com>; S200 <two@example.com>'
      end
    end
    assert_not_nil assigns(:project)
    assert_nil assigns(:design)
    assert_not_nil assigns(:site)
    assert_not_nil assigns(:emails)
    assert_redirected_to batch_project_designs_path(emails: assigns(:emails).join('; '), site_id: assigns(:site), design_id: assigns(:design) )
  end


  test "should not create batch with invalid project" do
    assert_difference('Sheet.count', 0) do
      assert_difference('Subject.count', 0) do
        post :create_batch, project_id: -1, design_id: @design, site_id: sites(:one), emails: 'S100 <one@example.com>; S200 <two@example.com>'
      end
    end
    assert_nil assigns(:project)
    assert_nil assigns(:design)
    assert_nil assigns(:site)
    assert_nil assigns(:emails)
    assert_redirected_to root_path
  end

  test "should get csv" do
    get :index, project_id: @project, format: 'csv'
    assert_not_nil assigns(:csv_string)
    assert_response :success
  end

  test "should not get csv if no designs are selected" do
    get :index, project_id: @project, format: 'csv', design_ids: [-1]
    assert_nil assigns(:designs)
    assert_nil assigns(:csv_string)
    assert_equal flash[:alert], 'No data was exported since no designs matched the specified filters.'
    assert_redirected_to project_designs_path(assigns(:project))
  end

  test "should get xls" do
    get :index, project_id: @project, format: 'xls'
    assert_not_nil assigns(:designs)
    assert_equal 'You will be emailed when the export is ready for download.', flash[:notice]
    assert_redirected_to project_designs_path(assigns(:project))
  end

  test "should get index" do
    get :index, project_id: @project
    assert_response :success
    assert_not_nil assigns(:designs)
  end

  test "should not get index with invalid project" do
    get :index, project_id: -1
    assert_nil assigns(:designs)
    assert_redirected_to root_path
  end

  test "should get paginated index" do
    get :index, project_id: @project, format: 'js'
    assert_not_nil assigns(:designs)
    assert_template 'index'
  end

  test "should get paginated index by project_name" do
    get :index, project_id: @project, format: 'js', order: 'designs.project_name'
    assert_not_nil assigns(:designs)
    assert_template 'index'
  end

  test "should get paginated index by project_name desc" do
    get :index, project_id: @project, format: 'js', order: 'designs.project_name DESC'
    assert_not_nil assigns(:designs)
    assert_template 'index'
  end

  test "should get paginated index by user_name" do
    get :index, project_id: @project, format: 'js', order: 'designs.user_name'
    assert_not_nil assigns(:designs)
    assert_template 'index'
  end

  test "should get paginated index by user_name desc" do
    get :index, project_id: @project, format: 'js', order: 'designs.user_name DESC'
    assert_not_nil assigns(:designs)
    assert_template 'index'
  end

  test "should get new" do
    get :new, project_id: @project
    assert_response :success
  end

  test "should create design" do
    assert_difference('Design.count') do
      post :create, project_id: @project, design: { description: "Design description", name: 'Design Three',
                              option_tokens: { "1338307879654" =>   { "variable_id" => ActiveRecord::Fixtures.identify(:dropdown) },
                                               "13383078795389" =>  { "variable_id" => ActiveRecord::Fixtures.identify(:checkbox) },
                                               "13383078797210" =>  { "variable_id" => ActiveRecord::Fixtures.identify(:radio) },
                                               "13383078798810" =>  { "variable_id" => ActiveRecord::Fixtures.identify(:string) },
                                               "133830787911168" => { "variable_id" => ActiveRecord::Fixtures.identify(:text) },
                                               "133830787913231" => { "variable_id" => ActiveRecord::Fixtures.identify(:integer) },
                                               "133830787914761" => { "variable_id" => ActiveRecord::Fixtures.identify(:numeric) },
                                               "133830787916252" => { "variable_id" => ActiveRecord::Fixtures.identify(:date) },
                                               "133830787917772" => { "variable_id" => ActiveRecord::Fixtures.identify(:file) }
                                             }
                            }
    end

    assert_not_nil assigns(:design)
    assert_equal 9, assigns(:design).variables.size
    assert_redirected_to project_design_path(assigns(:design).project, assigns(:design))
  end

  test "should not create design with invalid project" do
    assert_difference('Design.count', 0) do
      post :create, project_id: -1, design: { description: "Design description", name: 'Design Three', option_tokens: {} }
    end

    assert_nil assigns(:project)
    assert_nil assigns(:design)

    assert_redirected_to root_path
  end

  test "should not create design with a duplicated variable" do
    assert_difference('Design.count', 0) do
      post :create, project_id: @project, design: { description: "Design description", name: 'Design Three',
                              option_tokens: { "1338307879654" =>   { "variable_id" => ActiveRecord::Fixtures.identify(:dropdown) },
                                               "13383078795389" =>  { "variable_id" => ActiveRecord::Fixtures.identify(:dropdown) }
                                             }
                            }
    end

    assert_not_nil assigns(:design)
    assert_equal ["can only be added once"], assigns(:design).errors[:variables]
    assert_template 'new'
  end

  test "should not create design with a duplicated section name" do
    assert_difference('Design.count', 0) do
      post :create, project_id: @project, design: { description: "Design description", name: 'Design with Sections',
                              option_tokens: { "1338307879654" =>   { "section_name" => "Section A" },
                                               "13383078795389" =>  { "section_name" => "Section A" }
                                             }
                            }
    end

    assert_not_nil assigns(:design)
    assert_equal ["must be unique"], assigns(:design).errors[:section_names]
    assert_template 'new'
  end

  test "should show design" do
    get :show, id: @design, project_id: @project
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should show design for project with no sites" do
    get :show, id: designs(:no_sites), project_id: projects(:no_sites)
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should not show invalid design" do
    get :show, id: -1, project_id: @project
    assert_not_nil assigns(:project)
    assert_nil assigns(:design)
    assert_redirected_to project_designs_path(assigns(:project))
  end

  test "should not show design with invalid project" do
    get :show, id: @design, project_id: -1
    assert_nil assigns(:project)
    assert_nil assigns(:design)
    assert_redirected_to root_path
  end

  test "should print design" do
    get :print, id: @design, project_id: @project
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should not print invalid design" do
    get :print, id: -1, project_id: @project
    assert_nil assigns(:design)
    assert_redirected_to project_designs_path(assigns(:project))
  end

  test "should show design with all variable types" do
    get :show, id: designs(:all_variable_types), project_id: @project
    assert_response :success
  end

  test "should get variables" do
    post :variables, project_id: @project, design: { description: "New description", name: 'Design Four' }, format: 'js'
    assert_template 'variables'
    assert_response :success
  end

  test "should add section" do
    post :add_section, project_id: @project, design: { description: "New description", name: 'Design Four' }, format: 'js'
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:option)
    assert_template 'add_section'
    assert_response :success
  end

  test "should add variable" do
    post :add_variable, project_id: @project, design: { description: "New description", name: 'Design Four' }, format: 'js'
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:option)
    assert_template 'add_variable'
    assert_response :success
  end

  test "should get selection" do
    post :selection, project_id: @project, sheet: { design_id: designs(:all_variable_types).id }, format: 'js'
    assert_not_nil assigns(:sheet)
    assert_equal assigns(:design), designs(:all_variable_types)
    assert_template 'selection'
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @design, project_id: @project
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should not get edit for invalid design" do
    get :edit, id: -1, project_id: @project
    assert_not_nil assigns(:project)
    assert_nil assigns(:design)
    assert_redirected_to project_designs_path(assigns(:project))
  end

  test "should not get edit with invalid project" do
    get :edit, id: @design, project_id: -1
    assert_nil assigns(:project)
    assert_nil assigns(:design)
    assert_redirected_to root_path
  end

  test "should update design" do
    put :update, id: @design, project_id: @project, design: { description: @design.description, name: @design.name }
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_redirected_to project_design_path(assigns(:design).project, assigns(:design))
  end

  test "should not update design with blank name" do
    put :update, id: @design, project_id: @project, design: { description: @design.description, name: '' }
    assert_not_nil assigns(:design)
    assert assigns(:design).errors.size > 0
    assert_equal ["can't be blank"], assigns(:design).errors[:name]
    assert_template 'edit'
  end

  test "should not update invalid design" do
    put :update, id: -1, project_id: @project, design: { description: @design.description, name: @design.name }
    assert_not_nil assigns(:project)
    assert_nil assigns(:design)
    assert_redirected_to project_designs_path(assigns(:project))
  end

  test "should not update design with invalid project" do
    put :update, id: @design, project_id: -1, design: { description: @design.description, name: @design.name }
    assert_nil assigns(:project)
    assert_nil assigns(:design)
    assert_redirected_to root_path
  end

  test "should destroy design" do
    assert_difference('Design.current.count', -1) do
      delete :destroy, id: @design, project_id: @project
    end

    assert_redirected_to project_designs_path(assigns(:project))
  end

  test "should not destroy design with invalid project" do
    assert_difference('Design.current.count', 0) do
      delete :destroy, id: @design, project_id: -1
    end

    assert_nil assigns(:project)
    assert_nil assigns(:design)

    assert_redirected_to root_path
  end
end
