require 'test_helper'

class SheetsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @sheet = sheets(:one)
    @project = projects(:one)
  end

  test "should get project selection" do
    post :project_selection, project_id: @sheet.project_id, subject_code: @sheet.subject.subject_code, format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_not_nil assigns(:disable_selection)
    assert_nil assigns(:sheet_id)
    assert_nil assigns(:design)
    assert_template 'project_selection'
  end

  test "should get project selection with design selected" do
    post :project_selection, project_id: @sheet.project_id, subject_code: @sheet.subject.subject_code, sheet: { design_id: @sheet.design_id }, format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_not_nil assigns(:disable_selection)
    assert_nil assigns(:sheet_id)
    assert_not_nil assigns(:design)
    assert_template 'project_selection'
  end

  test "should get project selection for existing sheet" do
    post :project_selection, sheet_id: @sheet, project_id: @sheet.project_id, subject_code: @sheet.subject.subject_code, format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_not_nil assigns(:disable_selection)
    assert_not_nil assigns(:sheet_id)
    assert_not_nil assigns(:design)
    assert_template 'project_selection'
  end

  test "should get project selection for valid subject code for a new subject" do
    post :project_selection, project_id: projects(:one), subject_code: 'A200', format: 'js'
    assert_not_nil assigns(:project)
    assert_nil assigns(:subject)
    assert_not_nil assigns(:disable_selection)
    assert_not_nil assigns(:site)
    assert_equal true, assigns(:subject_code_valid)
    assert_template 'project_selection'
  end

  test "should send email without pdf attachment" do
    post :send_email, id: @sheet, project_id: @project, to: 'recipient@example.com', from: 'sender@example.com', cc: 'cc@example.com', subject: @sheet.email_subject_template(users(:valid)), body: @sheet.email_body_template(users(:valid))
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test "should send email with pdf attachment" do
    post :send_email, id: @sheet, project_id: @project, to: 'recipient@example.com', from: 'sender@example.com', cc: 'cc@example.com', subject: @sheet.email_subject_template(users(:valid)), body: @sheet.email_body_template(users(:valid)), pdf_attachment: '1'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test "should not send email for invalid sheet" do
    post :send_email, id: -1, project_id: @project, to: 'recipient@example.com', from: 'sender@example.com', cc: 'cc@example.com', subject: @sheet.email_subject_template(users(:valid)), body: @sheet.email_body_template(users(:valid))
    assert_not_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to project_sheets_path(assigns(:project))
  end

  test "should not send email for site user" do
    login(users(:site_one_user))
    post :send_email, id: @sheet, project_id: @project, to: 'recipient@example.com', from: 'sender@example.com', cc: 'cc@example.com', subject: @sheet.email_subject_template(users(:valid)), body: @sheet.email_body_template(users(:valid))
    assert_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to root_path
  end

  test "should get raw csv" do
    assert_difference('Export.count') do
      get :index, project_id: @project, export: '1', csv_raw: '1', format: 'js'
    end
    assert_response :success
  end

  test "should get labeled csv" do
    assert_difference('Export.count') do
      get :index, project_id: @project, export: '1', csv_labeled: '1', format: 'js'
    end
    assert_response :success
  end

  test "should get xls" do
    assert_difference('Export.count') do
      get :index, project_id: @project, export: '1', xls: '1', format: 'js'
    end
    assert_response :success
  end

  test "should get pdf collation" do
    assert_difference('Export.count') do
      get :index, project_id: @project, export: '1', pdf: '1', format: 'js'
    end
    assert_response :success
  end

  test "should get index" do
    get :index, project_id: @project
    assert_response :success
    assert_not_nil assigns(:sheets)
  end

  test "should get index with invalid project" do
    get :index, project_id: -1
    assert_nil assigns(:sheets)
    assert_redirected_to root_path
  end

  test "should get paginated index" do
    get :index, project_id: @project, format: 'js'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get index with row_include known" do
    get :index, project_id: @project, row_include: 'known', stratum_id: variables(:change_options), format: 'js'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get index with row_include missing" do
    get :index, project_id: @project, row_include: 'missing', stratum_id: variables(:change_options), format: 'js'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get index with row_include unknown" do
    get :index, project_id: @project, row_include: 'unknown', stratum_id: variables(:change_options), format: 'js'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get index with column_include known" do
    get :index, project_id: @project, column_include: 'known', column_stratum_id: variables(:change_options), format: 'js'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get index with column_include missing" do
    get :index, project_id: @project, column_include: 'missing', column_stratum_id: variables(:change_options), format: 'js'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get index with column_include unknown" do
    get :index, project_id: @project, column_include: 'unknown', column_stratum_id: variables(:change_options), format: 'js'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get index with site selected" do
    get :index, project_id: @project, stratum_value: sites(:one), format: 'js'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get index and set per page" do
    get :index, project_id: @project, format: 'js', sheets_per_page: 50
    assert_not_nil assigns(:sheets)
    assert_equal 50, users(:valid).reload.pagination_count('sheets')
    assert_template 'index'
  end

  test "should get paginated index order by site" do
    get :index, project_id: @project, order: 'sheets.site_name', format: 'js'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get paginated index order by site descending" do
    get :index, project_id: @project, order: 'sheets.site_name DESC', format: 'js'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end


  test "should get paginated index by design_name" do
    get :index, project_id: @project, format: 'js', order: 'sheets.design_name'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get paginated index by design_name desc" do
    get :index, project_id: @project, format: 'js', order: 'sheets.design_name DESC'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get paginated index by subject_code" do
    get :index, project_id: @project, format: 'js', order: 'sheets.subject_code'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get paginated index by subject_code desc" do
    get :index, project_id: @project, format: 'js', order: 'sheets.subject_code DESC'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get paginated index by project_name" do
    get :index, project_id: @project, format: 'js', order: 'sheets.project_name'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get paginated index by project_name desc" do
    get :index, project_id: @project, format: 'js', order: 'sheets.project_name DESC'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get paginated index by user_name" do
    get :index, project_id: @project, format: 'js', order: 'sheets.user_name'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get paginated index by user_name desc" do
    get :index, project_id: @project, format: 'js', order: 'sheets.user_name DESC'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should remove attached file" do
    post :remove_file, id: sheets(:file_attached), project_id: @project, sheet_variable_id: sheet_variables(:file_attachment), variable_id: variables(:file), position: nil, format: 'js'

    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:variable)
    assert_not_nil assigns(:sheet_variable)

    assert_template 'remove_file'
  end

  test "should not remove attached file" do
    login(users(:site_one_user))
    post :remove_file, id: sheets(:file_attached), project_id: @project, sheet_variable_id: sheet_variables(:file_attachment), variable_id: variables(:file), position: nil, format: 'js'

    assert_nil assigns(:sheet)
    assert_nil assigns(:variable)
    assert_nil assigns(:sheet_variable)

    assert_response :success
  end

  test "should get new" do
    get :new, project_id: @project
    assert_response :success
  end

  test "should get new and select the single design" do
    get :new, project_id: projects(:single_design)
    assert_not_nil assigns(:sheet)
    assert_equal designs(:single_design), assigns(:sheet).design
    assert_response :success
  end

  test "should not get new with invalid project" do
    get :new, project_id: -1
    assert_redirected_to root_path
  end

  test "should create sheet" do
    assert_difference('Sheet.count') do
      post :create, project_id: @project, sheet: { design_id: designs(:all_variable_types) },
                    subject_code: @sheet.subject.subject_code,
                    site_id: @sheet.subject.site_id,
                    variables: {
                      "#{variables(:dropdown).id}" => 'm',
                      "#{variables(:checkbox).id}" => ['acct101', 'econ101'],
                      "#{variables(:radio).id}" => '2',
                      "#{variables(:string).id}" => 'This is a string',
                      "#{variables(:text).id}" => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                      "#{variables(:integer).id}" => 30,
                      "#{variables(:numeric).id}" => 180.5,
                      "#{variables(:date).id}" => '05/28/2012',
                      "#{variables(:file).id}" => { response_file: '' },
                      "#{variables(:time).id}" => '14:30:00',
                      "#{variables(:calculated).id}" => '1234'
                    }
    end

    assert_not_nil assigns(:sheet)
    assert_equal 11, assigns(:sheet).variables.size

    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test "should create sheet and continue" do
    assert_difference('Sheet.count') do
      post :create, project_id: @project, sheet: { design_id: designs(:all_variable_types) },
                    subject_code: @sheet.subject.subject_code,
                    site_id: @sheet.subject.site_id,
                    continue: '1',
                    variables: {
                      "#{variables(:dropdown).id}" => 'm',
                      "#{variables(:checkbox).id}" => ['acct101', 'econ101'],
                      "#{variables(:radio).id}" => '2',
                      "#{variables(:string).id}" => 'This is a string',
                      "#{variables(:text).id}" => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                      "#{variables(:integer).id}" => 30,
                      "#{variables(:numeric).id}" => 180.5,
                      "#{variables(:date).id}" => '05/28/2012',
                      "#{variables(:file).id}" => { response_file: '' },
                      "#{variables(:time).id}" => '14:30:00',
                      "#{variables(:calculated).id}" => '1234'
                    }
    end

    assert_not_nil assigns(:sheet)
    assert_equal 11, assigns(:sheet).variables.size

    assert_redirected_to new_project_sheet_path(assigns(:sheet).project, sheet: { design_id: assigns(:sheet).design_id })
  end

  test "should create sheet with grid" do
    post :create, project_id: @project, sheet: { design_id: designs(:has_grid) },
                  subject_code: sheets(:has_grid).subject.subject_code,
                  site_id: sheets(:has_grid).subject.site_id,
                  variables: {
                    "#{variables(:grid).id}" => { "13463487147483201" => { "#{variables(:change_options).id}" => "1" },
                                                  "1346351022118849"  => { "#{variables(:change_options).id}" => "2" },
                                                  "1346351034600475"  => { "#{variables(:change_options).id}" => "3" }}
                  }

    assert_not_nil assigns(:sheet)
    assert_equal 1, assigns(:sheet).variables.size
    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test "should create new subject for different project" do
    assert_difference('Subject.count') do
      assert_difference('Sheet.count') do
        post :create, project_id: sheets(:two).project_id, sheet: { design_id: designs(:all_variable_types) }, subject_code: 'Code01', site_id: sites(:two).id
      end
    end

    assert_not_nil assigns(:sheet)
    assert_equal Subject.last, assigns(:sheet).subject

    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test "should create new validated subject" do
    assert_difference('Subject.count') do
      assert_difference('Sheet.count') do
        post :create, project_id: @project, sheet: { design_id: designs(:all_variable_types) }, subject_code: 'A400', site_id: sites(:valid_range).id
      end
    end

    assert_not_nil assigns(:sheet)
    assert_equal Subject.last, assigns(:sheet).subject
    assert_equal 'valid', assigns(:sheet).subject.status

    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

 test "should create new non-validated subject" do
    assert_difference('Subject.count') do
      assert_difference('Sheet.count') do
        post :create, project_id: @project, sheet: { design_id: designs(:all_variable_types) }, subject_code: 'A600', site_id: sites(:valid_range).id
      end
    end

    assert_not_nil assigns(:sheet)
    assert_equal Subject.last, assigns(:sheet).subject
    assert_equal 'pending', assigns(:sheet).subject.status

    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test "should create sheet and not alter status of existing subject" do
    assert_difference('Subject.count', 0) do
      assert_difference('Sheet.count') do
        post :create, project_id: @project, sheet: { design_id: designs(:all_variable_types) }, subject_code: 'A500', site_id: sites(:valid_range).id
      end
    end

    assert_not_nil assigns(:sheet)
    assert_equal subjects(:test_one).id, assigns(:sheet).subject.id
    assert_equal 'test', assigns(:sheet).subject.status

    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test "should not create sheet on invalid project" do
    assert_difference('Sheet.count', 0) do
      post :create, project_id: projects(:four), sheet: { design_id: @sheet.design_id },
                    subject_code: 'Code01',
                    site_id: @sheet.subject.site_id
    end

    assert_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to root_path
  end

  test "should not create sheet for site user" do
    login(users(:site_one_user))
    assert_difference('Sheet.count', 0) do
      post :create, project_id: @project, sheet: { design_id: @sheet.design_id },
                    subject_code: 'Code01',
                    site_id: sites(:one).id
    end

    assert_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to root_path
  end

  test "should not create sheet or subject if site_id is missing" do
    assert_difference('Sheet.count', 0) do
      assert_difference('Subject.count', 0) do
        post :create, project_id: @project, sheet: { design_id: @sheet.design_id },
                      subject_code: 'Code01'
      end
    end

    assert_not_nil assigns(:sheet)
    assert_equal ["can't be blank"], assigns(:sheet).errors[:subject_id]
    assert_template 'new'
    assert_response :success
  end

  test "should show sheet" do
    get :show, id: @sheet, project_id: @project
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test "should show sheet with ajax" do
    get :show, id: @sheet, project_id: @project, format: 'js'
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:project)
    assert_template 'show'
    assert_response :success
  end

  test "should get sheet survey using authentication_token" do
    get :survey, id: sheets(:external), project_id: sheets(:external).project, sheet_authentication_token: sheets(:external).authentication_token
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test "should not get sheet survey with invalid authentication_token" do
    get :survey, id: sheets(:external), project_id: sheets(:external).project, sheet_authentication_token: '123'
    assert_not_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_equal "Survey has already been submitted.", flash[:alert]
    assert_redirected_to new_user_session_path
  end

  test "should submit sheet survey using authentication_token" do
    post :submit_survey, id: sheets(:external), project_id: sheets(:external).project, sheet_authentication_token: sheets(:external).authentication_token
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_equal "Survey submitted successfully.", flash[:notice]
    assert_redirected_to about_path
  end

  test "should not submit sheet survey using invalid authentication_token" do
    post :submit_survey, id: sheets(:external), project_id: sheets(:external).project, sheet_authentication_token: '123'
    assert_not_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_equal "Survey has already been submitted.", flash[:alert]
    assert_redirected_to new_user_session_path
  end

  test "should show sheet audits" do
    get :audits, id: @sheet, project_id: @project
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test "should show sheet with completed email template" do
    get :show, id: sheets(:all_variables), project_id: @project
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:project)
    assert_equal "Dear #{assigns(:sheet).subject.site.name}: #{assigns(:sheet).subject.name} #{assigns(:sheet).subject.acrostic} #{variables(:dropdown).display_name} #{variables(:dropdown).response_name(assigns(:sheet))} #{assigns(:sheet).get_response(variables(:dropdown), :label)} #{assigns(:sheet).get_response(variables(:dropdown), :raw)} #{assigns(:sheet).get_response(variables(:checkbox), :label)} #{assigns(:sheet).get_response(variables(:integer), :label)} #{assigns(:sheet).get_response(variables(:file), :label)} #{assigns(:sheet).get_response(variables(:date), :label)}", assigns(:sheet).email_body_template(users(:valid))
    assert_response :success
  end

  test "should not show invalid sheet" do
    get :show, id: -1, project_id: @project
    assert_nil assigns(:sheet)
    assert_not_nil assigns(:project)
    assert_redirected_to project_sheets_path(@project)
  end

  test "should not show sheet with invalid project" do
    get :show, id: @sheet, project_id: -1
    assert_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to root_path
  end

  test "should not show audits for invalid sheet" do
    get :audits, id: -1, project_id: @project
    assert_not_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to project_sheets_path(@project)
  end

  test "should not show audits for invalid project" do
    get :audits, id: @sheet, project_id: -1
    assert_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to root_path
  end

  test "should not show sheet for user from different site" do
    login(users(:site_one_user))
    get :show, id: sheets(:three), project_id: @project
    assert_not_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to project_sheets_path(assigns(:project))
  end

  test "should print sheet" do
    get :print, id: @sheet, project_id: @project
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_response :success
  end

  test "should not print invalid sheet" do
    get :print, id: -1, project_id: @project
    assert_not_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to project_sheets_path(assigns(:project))
  end

  test "should get edit" do
    get :edit, id: @sheet, project_id: @project
    assert_response :success
  end

  test "should update sheet" do
    put :update, id: @sheet, project_id: @project, sheet: { design_id: designs(:all_variable_types) },
                    subject_code: @sheet.subject.subject_code,
                    site_id: @sheet.subject.site_id,
                    variables: {
                      "#{variables(:dropdown).id}" => 'f',
                      "#{variables(:checkbox).id}" => nil,
                      "#{variables(:radio).id}" => '1',
                      "#{variables(:string).id}" => 'This is an updated string',
                      "#{variables(:text).id}" => 'Lorem ipsum dolor sit amet',
                      "#{variables(:integer).id}" => 31,
                      "#{variables(:numeric).id}" => 190.5,
                      "#{variables(:date).id}" => '05/29/2012',
                      "#{variables(:file).id}" => { response_file: '' }
                    }

    assert_not_nil assigns(:sheet)
    assert_equal 9, assigns(:sheet).variables.size
    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test "should update sheet and continue" do
    put :update, id: @sheet, project_id: @project, sheet: { design_id: designs(:all_variable_types) },
                    subject_code: @sheet.subject.subject_code,
                    site_id: @sheet.subject.site_id,
                    continue: '1',
                    variables: {
                      "#{variables(:dropdown).id}" => 'f',
                      "#{variables(:checkbox).id}" => nil,
                      "#{variables(:radio).id}" => '1',
                      "#{variables(:string).id}" => 'This is an updated string',
                      "#{variables(:text).id}" => 'Lorem ipsum dolor sit amet',
                      "#{variables(:integer).id}" => 31,
                      "#{variables(:numeric).id}" => 190.5,
                      "#{variables(:date).id}" => '05/29/2012',
                      "#{variables(:file).id}" => { response_file: '' }
                    }

    assert_not_nil assigns(:sheet)
    assert_equal 9, assigns(:sheet).variables.size
    assert_redirected_to new_project_sheet_path(assigns(:sheet).project, sheet: { design_id: assigns(:sheet).design_id })
  end

  test "should not update invalid sheet" do
    put :update, id: -1, project_id: @project, sheet: { design_id: designs(:all_variable_types) }, subject_code: @sheet.subject.subject_code, site_id: @sheet.subject.site_id, variables: { }
    assert_not_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to project_sheets_path(@project)
  end

  test "should not update sheet with invalid project" do
    put :update, id: @sheet, project_id: -1, sheet: { design_id: designs(:all_variable_types) }, subject_code: @sheet.subject.subject_code, site_id: @sheet.subject.site_id, variables: { }
    assert_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to root_path
  end

  test "should destroy sheet" do
    assert_difference('Sheet.current.count', -1) do
      delete :destroy, id: @sheet, project_id: @project
    end

    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)

    assert_redirected_to project_sheets_path(@project)
  end

  test "should not destroy sheet with invalid project" do
    assert_difference('Sheet.current.count', 0) do
      delete :destroy, id: @sheet, project_id: -1
    end

    assert_nil assigns(:project)
    assert_nil assigns(:sheet)

    assert_redirected_to root_path
  end
end
