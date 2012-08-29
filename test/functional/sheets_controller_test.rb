require 'test_helper'

class SheetsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @sheet = sheets(:one)
  end

  test "should get project selection" do
    post :project_selection, project_id: @sheet.project_id, subject_code: @sheet.subject.subject_code, format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_not_nil assigns(:disable_selection)
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
    post :send_email, id: @sheet, to: 'recipient@example.com', from: 'sender@example.com', cc: 'cc@example.com', subject: @sheet.email_subject_template(users(:valid)), body: @sheet.email_body_template(users(:valid))
    assert_not_nil assigns(:sheet)
    assert_redirected_to assigns(:sheet)
  end

  test "should send email with pdf attachment" do
    post :send_email, id: @sheet, to: 'recipient@example.com', from: 'sender@example.com', cc: 'cc@example.com', subject: @sheet.email_subject_template(users(:valid)), body: @sheet.email_body_template(users(:valid)), pdf_attachment: '1'
    assert_not_nil assigns(:sheet)
    assert_redirected_to assigns(:sheet)
  end

  test "should not send email for site user" do
    login(users(:site_one_user))
    post :send_email, id: @sheet, to: 'recipient@example.com', from: 'sender@example.com', cc: 'cc@example.com', subject: @sheet.email_subject_template(users(:valid)), body: @sheet.email_body_template(users(:valid))
    assert_nil assigns(:sheet)
    assert_equal 'You do not have sufficient privileges to send a sheet receipt email.', flash[:alert]
    assert_redirected_to sheets_path
  end

  test "should get raw csv" do
    get :index, format: 'raw_csv'
    assert_not_nil assigns(:csv_string)
    assert_not_nil assigns(:sheet_count)
    assert_response :success
  end

  test "should get labeled csv" do
    get :index, format: 'labeled_csv'
    assert_not_nil assigns(:csv_string)
    assert_not_nil assigns(:sheet_count)
    assert_response :success
  end

  test "should get pdf collation" do
    get :index, format: 'scope'
    assert_not_nil assigns(:sheet_count)
    assert_not_nil assigns(:sheets)
    assert_template 'scope'
    assert_response :success
  end

  test "should not get raw csv when no sheets are selected" do
    get :index, format: 'raw_csv', project_id: -1
    assert_equal 0, assigns(:sheet_count)
    assert_redirected_to sheets_path
  end

  test "should not get labeled csv when no sheets are selected" do
    get :index, format: 'labeled_csv', project_id: -1
    assert_equal 0, assigns(:sheet_count)
    assert_redirected_to sheets_path
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sheets)
  end

  test "should get paginated index" do
    get :index, format: 'js'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get index and set per page" do
    get :index, format: 'js', sheets_per_page: 50
    assert_not_nil assigns(:sheets)
    assert_equal 50, users(:valid).reload.pagination_count('sheets')
    assert_template 'index'
  end

  test "should get paginated index order by site" do
    get :index, order: 'sheets.site_name', format: 'js'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get paginated index order by site descending" do
    get :index, order: 'sheets.site_name DESC', format: 'js'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end


  test "should get paginated index by design_name" do
    get :index, format: 'js', order: 'sheets.design_name'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get paginated index by design_name desc" do
    get :index, format: 'js', order: 'sheets.design_name DESC'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get paginated index by subject_code" do
    get :index, format: 'js', order: 'sheets.subject_code'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get paginated index by subject_code desc" do
    get :index, format: 'js', order: 'sheets.subject_code DESC'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get paginated index by project_name" do
    get :index, format: 'js', order: 'sheets.project_name'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get paginated index by project_name desc" do
    get :index, format: 'js', order: 'sheets.project_name DESC'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get paginated index by user_name" do
    get :index, format: 'js', order: 'sheets.user_name'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get paginated index by user_name desc" do
    get :index, format: 'js', order: 'sheets.user_name DESC'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should remove attached file" do
    post :remove_file, id: sheets(:file_attached), variable_id: variables(:file), format: 'js'

    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:variable)
    assert_not_nil assigns(:sheet_variable)

    assert_template 'remove_file'
  end

  test "should not remove attached file" do
    login(users(:site_one_user))
    post :remove_file, id: sheets(:file_attached), variable_id: variables(:file), format: 'js'

    assert_nil assigns(:sheet)
    assert_nil assigns(:variable)
    assert_nil assigns(:sheet_variable)

    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sheet" do
    assert_difference('Sheet.count') do
      post :create, sheet: { design_id: designs(:all_variable_types), project_id: @sheet.project_id, study_date: '05/23/2012' },
                    subject_code: @sheet.subject.subject_code,
                    site_id: @sheet.subject.site_id,
                    current_design_page: 2,
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

    assert_redirected_to sheet_path(assigns(:sheet))
  end

  test "should create new subject for different project" do
    assert_difference('Subject.count') do
      assert_difference('Sheet.count') do
        post :create, sheet: { design_id: designs(:all_variable_types), project_id: sheets(:two).project_id, study_date: '05/23/2012' }, subject_code: 'Code01', site_id: sites(:two).id, current_design_page: 2
      end
    end

    assert_not_nil assigns(:sheet)
    assert_equal Subject.last, assigns(:sheet).subject

    assert_redirected_to sheet_path(assigns(:sheet))
  end

  test "should create new validated subject" do
    assert_difference('Subject.count') do
      assert_difference('Sheet.count') do
        post :create, sheet: { design_id: designs(:all_variable_types), project_id: @sheet.project_id, study_date: '05/23/2012' }, subject_code: 'A400', site_id: sites(:valid_range).id, current_design_page: 2
      end
    end

    assert_not_nil assigns(:sheet)
    assert_equal Subject.last, assigns(:sheet).subject
    assert_equal true, assigns(:sheet).subject.validated?

    assert_redirected_to sheet_path(assigns(:sheet))
  end

 test "should create new non-validated subject" do
    assert_difference('Subject.count') do
      assert_difference('Sheet.count') do
        post :create, sheet: { design_id: designs(:all_variable_types), project_id: @sheet.project_id, study_date: '05/23/2012' }, subject_code: 'A600', site_id: sites(:valid_range).id, current_design_page: 2
      end
    end

    assert_not_nil assigns(:sheet)
    assert_equal Subject.last, assigns(:sheet).subject
    assert_equal false, assigns(:sheet).subject.validated?

    assert_redirected_to sheet_path(assigns(:sheet))
  end

  test "should not create sheet on same design project subject study_date" do
    assert_difference('Sheet.count', 0) do
      post :create, sheet: { design_id: @sheet.design_id, project_id: @sheet.project_id, study_date: '05/21/2012' },
                    subject_code: 'Code01',
                    site_id: @sheet.subject.site_id,
                    current_design_page: 2
    end

    assert_not_nil assigns(:sheet)
    assert_equal ['has already been taken'], assigns(:sheet).errors[:study_date]
    assert_template 'new'
    assert_response :success
  end

  test "should not create sheet on invalid project" do
    assert_difference('Sheet.count', 0) do
      post :create, sheet: { design_id: @sheet.design_id, project_id: projects(:four), study_date: '05/21/2012' },
                    subject_code: 'Code01',
                    site_id: @sheet.subject.site_id,
                    current_design_page: 2
    end

    assert_not_nil assigns(:sheet)
    assert_equal ["can't be blank"], assigns(:sheet).errors[:project_id]
    assert_template 'new'
    assert_response :success
  end

  test "should not create sheet for site user" do
    login(users(:site_one_user))
    assert_difference('Sheet.count', 0) do
      post :create, sheet: { design_id: @sheet.design_id, project_id: projects(:one), study_date: '05/21/2012' },
                    subject_code: 'Code01',
                    site_id: sites(:one).id,
                    current_design_page: 2
    end

    assert_not_nil assigns(:sheet)
    assert_equal ["can't be blank"], assigns(:sheet).errors[:project_id]
    assert_template 'new'
    assert_response :success
  end

  test "should not create sheet or subject if site_id is missing" do
    assert_difference('Sheet.count', 0) do
      assert_difference('Subject.count', 0) do
        post :create, sheet: { design_id: @sheet.design_id, project_id: @sheet.project_id, study_date: '05/21/2012' },
                      subject_code: 'Code01', current_design_page: 2
      end
    end

    assert_not_nil assigns(:sheet)
    assert_equal ["can't be blank"], assigns(:sheet).errors[:subject_id]
    assert_template 'new'
    assert_response :success
  end

  test "should show sheet" do
    get :show, id: @sheet
    assert_not_nil assigns(:sheet)
    assert_response :success
  end

  test "should show sheet with completed email template" do
    get :show, id: sheets(:all_variables)
    assert_not_nil assigns(:sheet)
    assert_equal "Dear #{assigns(:sheet).subject.site.name}: #{assigns(:sheet).subject.name} #{assigns(:sheet).subject.acrostic} #{assigns(:sheet).study_date.strftime("%Y-%m-%d")} #{variables(:dropdown).display_name} #{variables(:dropdown).response_name(assigns(:sheet))} #{variables(:dropdown).response_label(assigns(:sheet))} #{variables(:dropdown).response_raw(assigns(:sheet))} #{variables(:checkbox).response_label(assigns(:sheet))} #{variables(:integer).response_label(assigns(:sheet))} #{variables(:file).response_label(assigns(:sheet))} #{variables(:date).response_label(assigns(:sheet))}", assigns(:sheet).email_body_template(users(:valid))
    assert_response :success
  end

  test "should not show invalid sheet" do
    get :show, id: -1
    assert_nil assigns(:sheet)
    assert_redirected_to sheets_path
  end

  test "should not show sheet for user from different site" do
    login(users(:site_one_user))
    get :show, id: sheets(:three)
    assert_nil assigns(:sheet)
    assert_redirected_to sheets_path
  end

  test "should print sheet" do
    get :print, id: @sheet
    assert_not_nil assigns(:sheet)
    assert_response :success
  end

  test "should not print invalid sheet" do
    get :print, id: -1
    assert_nil assigns(:sheet)
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sheet
    assert_response :success
  end

  test "should update sheet" do
    put :update, id: @sheet, sheet: { design_id: designs(:all_variable_types), project_id: @sheet.project_id, study_date: '05/23/2012' },
                    subject_code: @sheet.subject.subject_code,
                    site_id: @sheet.subject.site_id,
                    current_design_page: 2,
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
    assert_redirected_to sheet_path(assigns(:sheet))
  end

  test "should not update sheet with blank study date" do
    put :update, id: @sheet, sheet: { design_id: designs(:all_variable_types), project_id: @sheet.project_id, study_date: '' }, subject_code: @sheet.subject.subject_code, site_id: @sheet.subject.site_id, current_design_page: 2, variables: { }
    assert_not_nil assigns(:sheet)
    assert_equal ["can't be blank"], assigns(:sheet).errors[:study_date]
    assert_template 'edit'
  end

  test "should not update invalid sheet" do
    put :update, id: -1, sheet: { design_id: designs(:all_variable_types), project_id: @sheet.project_id, study_date: '05/23/2012' }, subject_code: @sheet.subject.subject_code, site_id: @sheet.subject.site_id, current_design_page: 2, variables: { }
    assert_nil assigns(:sheet)
    assert_redirected_to sheets_path
  end

  test "should destroy sheet" do
    assert_difference('Sheet.current.count', -1) do
      delete :destroy, id: @sheet
    end

    assert_redirected_to sheets_path
  end
end
