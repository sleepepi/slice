require 'test_helper'

class DesignsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @project = projects(:one)
    @design = designs(:one)
  end

  test "should show design overview" do
    get :overview, id: @design, project_id: @project
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should show design overview with ajax" do
    get :overview, id: @design, project_id: @project, format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_template 'overview'
  end

  test "should get public survey" do
    post :survey, id: designs(:admin_public_design), project_id: projects(:three)
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_equal true, assigns(:design).publicly_available
    assert_response :success
  end

  test "should not get private survey" do
    assert_equal false, designs(:admin_design).publicly_available
    post :survey, id: designs(:admin_design), project_id: projects(:three)
    assert_not_nil assigns(:project)
    assert_nil assigns(:design)
    assert_redirected_to about_path
  end

  test "should show progress" do
    post :progress, id: @design, project_id: @project, format: 'js'
    assert_not_nil assigns(:design)
    assert_template 'progress'
    assert_response :success
  end

  test "should get import" do
    get :import, project_id: @project
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:variables)
    assert_response :success
  end

  test "should require file before proceeding to column specification for design imports" do
    post :create_import, project_id: @project,
                         design: { csv_file: '' }

    assert_equal 0, assigns(:variables).size
    assert assigns(:design).errors.size > 0
    assert_equal ["must be selected"], assigns(:design).errors[:csv_file]

    assert_template 'import'
    assert_response :success
  end

  test "should import data for new design" do
    assert_difference('Design.count', 1) do
      assert_difference('Variable.count', 5) do
        post :create_import, project_id: @project,
                             design: { csv_file: fixture_file_upload('../../test/support/design_import.csv'), name: 'Design Import' },
                             variables: { "store_id" => { display_name: 'Store ID', variable_type: 'integer' },
                                          "gpa" => { display_name: 'GPA', variable_type: 'numeric' },
                                          "buy_date" => { display_name: 'Buy Date', variable_type: 'date' },
                                          "name" => { display_name: 'First Name', variable_type: 'string' },
                                          "gender" => { display_name: 'Gender', variable_type: 'string' } }
      end
    end
    assert_equal 'Design import initialized successfully. You will receive an email when the design import completes.', flash[:notice]
    assert_redirected_to project_design_path(assigns(:design).project, assigns(:design))
  end

  test "should not import data for new design with blank name" do
    assert_difference('Design.count', 0) do
      assert_difference('Variable.count', 0) do
        post :create_import, project_id: @project,
                             design: { csv_file: fixture_file_upload('../../test/support/design_import.csv'), name: '' },
                             variables: { "store_id" => { display_name: 'Store ID', variable_type: 'integer' },
                                          "gpa" => { display_name: 'GPA', variable_type: 'numeric' },
                                          "buy_date" => { display_name: 'Buy Date', variable_type: 'date' },
                                          "name" => { display_name: 'First Name', variable_type: 'string' },
                                          "gender" => { display_name: 'Gender', variable_type: 'string' } }
      end
    end
    assert_equal 5, assigns(:variables).size
    assert_template 'import'
    assert_response :success
  end

  test "should load file and present importable columns for new design with blank header columns (columns with blank headers are ignored)" do
    post :create_import, project_id: @project,
                         design: { csv_file: fixture_file_upload('../../test/support/design_import_with_blank_columns.csv') }

    assert_equal 4, assigns(:variables).size

    assert_template 'import'
    assert_response :success
  end

  test "should import data for new design with blank header columns" do
    assert_difference('Design.count', 1) do
      assert_difference('Variable.count', 4) do
        post :create_import, project_id: @project,
                             design: { csv_file: fixture_file_upload('../../test/support/design_import_with_blank_columns.csv'), name: 'Design Import' },
                             variables: { "gpa" => { display_name: 'GPA', variable_type: 'numeric' },
                                          "buy_date" => { display_name: 'Buy Date', variable_type: 'date' },
                                          "name" => { display_name: 'First Name', variable_type: 'string' },
                                          "gender" => { display_name: 'Gender', variable_type: 'string' } }
      end
    end
    assert_equal 'Design import initialized successfully. You will receive an email when the design import completes.', flash[:notice]
    assert_redirected_to project_design_path(assigns(:design).project, assigns(:design))
  end

  test "should get reimport" do
    get :reimport, id: @design, project_id: @project
    assert_not_nil assigns(:design)
    assert_not_nil assigns(:variables)
    assert_response :success
  end

  test "should require file before proceeding to column specification for updating design imports" do
    patch :update_import, id: @design, project_id: @project, design: { csv_file: '' }

    assert_equal 0, assigns(:variables).size
    assert assigns(:design).errors.size > 0
    assert_equal ["must be selected"], assigns(:design).errors[:csv_file]

    assert_template 'reimport'
    assert_response :success
  end

  test "should reimport data for existing design" do
    assert_difference('Design.count', 0) do
      assert_difference('Variable.count', 0) do
        post :update_import, id: @design, project_id: @project,
                             design: { csv_file: fixture_file_upload('../../test/support/design_import.csv') },
                             variables: { "store_id" => { display_name: 'Store ID', variable_type: 'integer' },
                                          "gpa" => { display_name: 'GPA', variable_type: 'numeric' },
                                          "buy_date" => { display_name: 'Buy Date', variable_type: 'date' },
                                          "name" => { display_name: 'First Name', variable_type: 'string' },
                                          "gender" => { display_name: 'Gender', variable_type: 'string' } }
      end
    end
    assert_equal 'Design import initialized successfully. You will receive an email when the design import completes.', flash[:notice]
    assert_redirected_to project_design_path(assigns(:design).project, assigns(:design))
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
    get :report, id: @design, project_id: @project, f: [{ id: variables(:one).id, axis: 'row', missing: '1' }]
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should get report with row variable (dropdown) and exclude missing" do
    get :report, id: @design, project_id: @project, f: [{ id: variables(:one).id, axis: 'row', missing: '0' }]
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should get report with column variable (dropdown)" do
    get :report, id: @design, project_id: @project, f: [{ id: variables(:one).id, axis: 'col', missing: '1' }]
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should get report string (row) by sheet date (col)" do
    get :report, id: @design, project_id: @project, f: [{ id: variables(:string).id, axis: 'row', missing: '1' }, { id: 'sheet_date', axis: 'col', missing: '0' }]
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should get report with column variable (date)" do
    get :report, id: @design, project_id: @project, f: [{ id: variables(:date).id, axis: 'col', missing: '1' }]
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should get report with column variable (numeric)" do
    get :report, id: designs(:all_variable_types), project_id: @project, f: [{ id: variables(:numeric).id, axis: 'col', missing: '1' }]
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should get report with column variable (numeric) and first sheet only" do
    get :report, id: designs(:all_variable_types), project_id: @project, f: [{ id: variables(:numeric).id, axis: 'col', missing: '1' }], filter: 'first'
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should get report with column variable (numeric) and last sheet only" do
    get :report, id: designs(:all_variable_types), project_id: @project, f: [{ id: variables(:numeric).id, axis: 'col', missing: '1' }], filter: 'last'
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should get report gender (row) by weight (column)" do
    get :report, id: designs(:weight_and_gender), project_id: @project, f: [{ id: variables(:gender).id, axis: 'row', missing: '0' }, { id: variables(:weight).id, axis: 'col', missing: '0' }], statuses: [ 'valid', 'test' ]
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should get report weight (row) by site (column)" do
    get :report, id: designs(:weight_and_gender), project_id: @project, f: [{ id: variables(:weight).id, axis: 'row', missing: '0' }, { id: 'site', axis: 'col', missing: '0' }], statuses: [ 'valid', 'test' ]
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should get report site and gender (row) by weight (column)" do
    get :report, id: designs(:weight_and_gender), project_id: @project, f: [{ id: 'site', axis: 'row', missing: '0' }, { id: variables(:gender).id, axis: 'row', missing: '1' }, { id: variables(:weight).id, axis: 'col', missing: '1' }], statuses: [ 'valid', 'test' ]
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should get report as a CSV" do
    get :report, id: @design, project_id: @project, format: 'csv'
    assert_not_nil assigns(:design)
    assert_response :success
  end

  test "should get report site and gender (row) by weight (column) as CSV" do
    get :report, id: designs(:weight_and_gender), project_id: @project, f: [{ id: 'site', axis: 'row', missing: '0' }, { id: variables(:gender).id, axis: 'row', missing: '1' }, { id: variables(:weight).id, axis: 'col', missing: '1' }], statuses: [ 'valid', 'test' ], format: 'csv'
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
    assert_difference('Design.count') do
      get :copy, id: @design, project_id: @project
    end

    assert_not_nil assigns(:design)
    assert_equal @design.name + " Copy", assigns(:design).name
    assert_redirected_to edit_project_design_path(assigns(:design).project, assigns(:design))
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
    assert_equal [ActiveRecord::FixtureSet.identify(:two), ActiveRecord::FixtureSet.identify(:one), ActiveRecord::FixtureSet.identify(:date)], assigns(:design).options.collect{|option| option[:variable_id]}
    assert_template 'reorder'
  end

  test "should reorder sections" do
    post :reorder, id: designs(:sections_and_variables), project_id: @project, sections: "section_1,section_0", format: 'js'
    assert_not_nil assigns(:design)
    assert_equal [
                    ActiveRecord::FixtureSet.identify(:date),
                    'Section B',
                    ActiveRecord::FixtureSet.identify(:string),
                    ActiveRecord::FixtureSet.identify(:text),
                    ActiveRecord::FixtureSet.identify(:integer),
                    ActiveRecord::FixtureSet.identify(:numeric),
                    ActiveRecord::FixtureSet.identify(:file),
                    'Section A',
                    ActiveRecord::FixtureSet.identify(:dropdown),
                    ActiveRecord::FixtureSet.identify(:checkbox),
                    ActiveRecord::FixtureSet.identify(:radio)
                 ], assigns(:design).options.collect{|option| option[:variable_id].blank? ? option[:section_name] : option[:variable_id]}
    assert_template 'reorder'
  end

  test "should reorder sections (keep same order)" do
    post :reorder, id: designs(:sections_and_variables), project_id: @project, sections: "section_0,section_1", format: 'js'
    assert_not_nil assigns(:design)

    assert_equal [
                    ActiveRecord::FixtureSet.identify(:date),
                    'Section A',
                    ActiveRecord::FixtureSet.identify(:dropdown),
                    ActiveRecord::FixtureSet.identify(:checkbox),
                    ActiveRecord::FixtureSet.identify(:radio),
                    'Section B',
                    ActiveRecord::FixtureSet.identify(:string),
                    ActiveRecord::FixtureSet.identify(:text),
                    ActiveRecord::FixtureSet.identify(:integer),
                    ActiveRecord::FixtureSet.identify(:numeric),
                    ActiveRecord::FixtureSet.identify(:file)
                 ], assigns(:design).options.collect{|option| option[:variable_id].blank? ? option[:section_name] : option[:variable_id]}
    assert_template 'reorder'
  end

  test "should not reorder sections with different section count" do
    post :reorder, id: designs(:sections_and_variables), project_id: @project, sections: "section_1", format: 'js'
    assert_not_nil assigns(:design)
    assert_equal [
                ActiveRecord::FixtureSet.identify(:date),
                'Section A',
                ActiveRecord::FixtureSet.identify(:dropdown),
                ActiveRecord::FixtureSet.identify(:checkbox),
                ActiveRecord::FixtureSet.identify(:radio),
                'Section B',
                ActiveRecord::FixtureSet.identify(:string),
                ActiveRecord::FixtureSet.identify(:text),
                ActiveRecord::FixtureSet.identify(:integer),
                ActiveRecord::FixtureSet.identify(:numeric),
                ActiveRecord::FixtureSet.identify(:file)
             ], assigns(:design).options.collect{|option| option[:variable_id].blank? ? option[:section_name] : option[:variable_id]}
    assert_template 'reorder'
  end

  test "should not reorder for invalid design" do
    login(users(:site_one_viewer))
    post :reorder, id: designs(:sections_and_variables), project_id: @project, sections: "section_0,section_1", format: 'js'
    assert_nil assigns(:design)
    assert_response :success
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

  test "should get new with ajax" do
    get :new, project_id: @project, format: 'js'
    assert_template 'edit'
    assert_response :success
  end

  test "should create design" do
    assert_difference('Design.count') do
      post :create, project_id: @project, design: { name: 'Design Three' }, format: 'js'
    end

    assert_not_nil assigns(:design)
    assert_redirected_to edit_project_design_path(assigns(:design).project, assigns(:design))
  end

  test "should create design and save parseable redirect_url" do
    assert_difference('Design.count') do
      post :create, project_id: @project, design: { name: 'Public with Valid Redirect', redirect_url: 'http://example.com' }, format: 'js'
    end

    assert_not_nil assigns(:design)

    assert_equal 'http://example.com', assigns(:design).redirect_url

    assert_redirected_to edit_project_design_path(assigns(:design).project, assigns(:design))
  end

  test "should create design but not save non http redirect_url" do
    assert_difference('Design.count') do
      post :create, project_id: @project, design: { name: 'Public with Invalid Redirect', redirect_url: 'fake123' }, format: 'js'
    end

    assert_not_nil assigns(:design)

    assert_equal '', assigns(:design).redirect_url

    assert_redirected_to edit_project_design_path(assigns(:design).project, assigns(:design))
  end

  test "should create design but not save nonparseable redirect_url" do
    assert_difference('Design.count') do
      post :create, project_id: @project, design: { name: 'Public with Invalid Redirect', redirect_url: 'fa\\ke' }, format: 'js'
    end

    assert_not_nil assigns(:design)
    assert_equal '', assigns(:design).redirect_url

    assert_redirected_to edit_project_design_path(assigns(:design).project, assigns(:design))
  end

  test "should not create design with invalid project" do
    assert_difference('Design.count', 0) do
      post :create, project_id: -1, design: { name: 'Design Three' }, format: 'js'
    end

    assert_nil assigns(:project)
    assert_nil assigns(:design)

    assert_response :success
  end

  # test "should not create design with a duplicated variable" do
  #   assert_difference('Design.count', 0) do
  #     post :create, project_id: @project, design: { description: "Design description", name: 'Design Three',
  #                             option_tokens: [ { "variable_id" => ActiveRecord::FixtureSet.identify(:dropdown) },
  #                                              { "variable_id" => ActiveRecord::FixtureSet.identify(:dropdown) }
  #                                            ]
  #                           }
  #   end

  #   assert_not_nil assigns(:design)
  #   assert_equal ["can only be added once"], assigns(:design).errors[:variables]
  #   assert_template 'new'
  # end

  # test "should not create design with a duplicated section name" do
  #   assert_difference('Design.count', 0) do
  #     post :create, project_id: @project, design: { description: "Design description", name: 'Design with Sections',
  #                             option_tokens: [ { "section_name" => "Section A" },
  #                                              { "section_name" => "Section A" }
  #                                            ]
  #                           }
  #   end

  #   assert_not_nil assigns(:design)
  #   assert_equal ["must be unique"], assigns(:design).errors[:section_names]
  #   assert_template 'new'
  # end

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
    get :print, id: designs(:all_variable_types), project_id: @project
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

  test "should get selection" do
    post :selection, project_id: @project, sheet: { design_id: designs(:all_variable_types).id }, format: 'js'
    assert_not_nil assigns(:sheet)
    assert_equal assigns(:design), designs(:all_variable_types)
    assert_template 'selection'
    assert_response :success
  end

  test "should get selection for design with two scale variables" do
    post :selection, project_id: @project, sheet: { design_id: designs(:two_scale_variables).id }, format: 'js'
    assert_not_nil assigns(:sheet)
    assert_equal assigns(:design), designs(:two_scale_variables)
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
    put :update, id: @design, project_id: @project, design: { description: "Updated Description" }, format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_template 'update'
  end

  # test "should not update design with blank name" do
  #   put :update, id: @design, project_id: @project, design: { description: @design.description, name: '' }
  #   assert_not_nil assigns(:design)
  #   assert assigns(:design).errors.size > 0
  #   assert_equal ["can't be blank"], assigns(:design).errors[:name]
  #   assert_template 'edit'
  # end

  # test "should not update invalid design" do
  #   put :update, id: -1, project_id: @project, design: { description: @design.description, name: @design.name }
  #   assert_not_nil assigns(:project)
  #   assert_nil assigns(:design)
  #   assert_redirected_to project_designs_path(assigns(:project))
  # end

  # test "should not update design with invalid project" do
  #   put :update, id: @design, project_id: -1, design: { description: @design.description, name: @design.name }
  #   assert_nil assigns(:project)
  #   assert_nil assigns(:design)
  #   assert_redirected_to root_path
  # end

  test "should create a section on a design" do
    put :update, id: @design, project_id: @project, section: { section_name: 'Section A', section_description: 'Section Description' }, position: 0, create: 'section', format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_equal 4, assigns(:design).options.size
    assert_equal 'Section A', assigns(:design).options[0][:section_name]
    assert_equal 'Section Description', assigns(:design).options[0][:section_description]
    assert_template 'update'
  end

  test "should update an existing section on a design" do
    put :update, id: designs(:sections_and_variables), project_id: @project, section: { section_name: 'Section A Updated', section_description: 'Section Description' }, position: 1, update: 'section', format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_equal 11, assigns(:design).options.size
    assert_equal 'Section A Updated', assigns(:design).options[1][:section_name]
    assert_equal 'Section Description', assigns(:design).options[1][:section_description]
    assert_template 'update'
  end

  test "should create a variable and add it to design" do
    assert_difference('Variable.current.count') do
      put :update, id: @design, project_id: @project, variable: { display_name: 'My New Variable', name: 'my_new_variable', variable_type: 'string' }, position: 0, create: 'variable', format: 'js'
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_equal 4, assigns(:design).options.size
    assert_equal 'my_new_variable', assigns(:design).variable_at(0).name
    assert_equal 'My New Variable', assigns(:design).variable_at(0).display_name
    assert_equal 'string', assigns(:design).variable_at(0).variable_type
    assert_template 'update'
  end

  test "should remove a variable from a design" do
    put :update, id: @design, project_id: @project, position: 0, delete: 'variable', format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_equal 2, assigns(:design).options.size
    assert_template 'update'
  end

  test "should create a domain and add it to the first variable on the design" do
    assert_difference('Domain.current.count') do
      put :update, id: @design, project_id: @project, domain: { name: 'new_domain_for_variable', display_name: 'New Domain For Variable', option_tokens: [ { option_index: 'new', name: 'Easy', value: '1' }, { option_index: 'new', name: 'Medium', value: '2' }, { option_index: 'new', name: 'Hard', value: '3' }, { option_index: 'new', name: 'Old Value', value: 'Value' } ] }, position: 0, variable_id: variables(:one).id, create: 'domain', format: 'js'
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:design)
    assert_equal 3, assigns(:design).options.size
    assert_equal 'new_domain_for_variable', assigns(:design).variable_at(0).domain.name
    assert_template 'update'
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
