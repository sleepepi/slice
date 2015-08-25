require 'test_helper'

class SheetsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @sheet = sheets(:one)
    @project = projects(:one)
  end

  test "should get raw csv" do
    assert_difference('Export.count') do
      xhr :get, :index, project_id: @project, export: '1', csv_raw: '1', format: 'js'
    end
    assert_response :success
  end

  test "should get labeled csv" do
    assert_difference('Export.count') do
      xhr :get, :index, project_id: @project, export: '1', csv_labeled: '1', format: 'js'
    end
    assert_response :success
  end

  test "should get pdf collation" do
    assert_difference('Export.count') do
      xhr :get, :index, project_id: @project, export: '1', pdf: '1', format: 'js'
    end
    assert_response :success
  end

  test "should get index" do
    get :index, project_id: @project
    assert_response :success
    assert_not_nil assigns(:sheets)
  end

  test "should get index and filter by locked sheets" do
    get :index, project_id: @project, locked: '1'
    assert_not_nil assigns(:sheets)
    assert_equal 1, assigns(:sheets).count
    assert_response :success
  end

  test "should get index with invalid project" do
    get :index, project_id: -1
    assert_nil assigns(:sheets)
    assert_redirected_to root_path
  end

  test "should get paginated index" do
    get :index, project_id: @project, page: 2
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get paginated index order by site" do
    get :index, project_id: @project, order: 'sheets.site_name'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get paginated index order by site descending" do
    get :index, project_id: @project, order: 'sheets.site_name DESC'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end


  test "should get index by design_name" do
    get :index, project_id: @project, order: 'sheets.design_name'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get index by design_name desc" do
    get :index, project_id: @project, order: 'sheets.design_name DESC'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get index by subject_code" do
    get :index, project_id: @project, order: 'sheets.subject_code'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get index by subject_code desc" do
    get :index, project_id: @project, order: 'sheets.subject_code DESC'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get index by project_name" do
    get :index, project_id: @project, order: 'sheets.project_name'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get index by project_name desc" do
    get :index, project_id: @project, order: 'sheets.project_name DESC'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get index by user_name" do
    get :index, project_id: @project, order: 'sheets.user_name'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get index by user_name desc" do
    get :index, project_id: @project, order: 'sheets.user_name DESC'
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test "should get attached file" do
    assert_not_equal 0, sheet_variables(:file_attachment).response_file.size
    get :file, id: sheets(:file_attached), project_id: @project, sheet_variable_id: sheet_variables(:file_attachment), variable_id: variables(:file), position: nil

    assert_not_nil response
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:sheet_variable)
    assert_not_nil assigns(:object)

    assert_kind_of String, response.body
    assert_equal File.binread( File.join(CarrierWave::Uploader::Base.root, assigns(:object).response_file.url) ), response.body
  end

  test "should get attached file in grid" do
    assert_not_equal 0, grids(:has_grid_row_one_attached_file).response_file.size
    get :file, id: sheets(:has_grid_with_file), project_id: @project, sheet_variable_id: sheet_variables(:has_grid_with_file), variable_id: variables(:file), position: 0

    assert_not_nil response
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:sheet_variable)
    assert_not_nil assigns(:object)

    assert_kind_of String, response.body
    assert_equal File.binread( File.join(CarrierWave::Uploader::Base.root, assigns(:object).response_file.url) ), response.body
  end

  test "should not get non-existent file in grid" do
    assert_equal 0, grids(:has_grid_row_two_no_attached_file).response_file.size
    get :file, id: sheets(:has_grid_with_file), project_id: @project, sheet_variable_id: sheet_variables(:has_grid_with_file), variable_id: variables(:file), position: 1

    assert_not_nil response
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:sheet_variable)
    assert_not_nil assigns(:object)
    assert_equal 0, assigns(:object).response_file.size

    assert_response :success
  end

  test "should not get attached file for viewer on different site" do
    login(users(:site_one_viewer))
    assert_not_equal 0, sheet_variables(:file_attachment).response_file.size
    get :file, id: sheets(:file_attached), project_id: @project, sheet_variable_id: sheet_variables(:file_attachment), variable_id: variables(:file), position: nil

    assert_not_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_nil assigns(:variable)
    assert_nil assigns(:sheet_variable)

    assert_redirected_to project_sheets_path(assigns(:project))
  end

  test "should get new" do
    get :new, project_id: @project
    assert_response :success
  end

  test "should get new as site editor" do
    login(users(:site_one_editor))
    get :new, project_id: @project
    assert_response :success
  end

  test "should not get new as site viewer" do
    login(users(:site_one_viewer))
    get :new, project_id: @project
    assert_redirected_to root_path
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
    assert_difference('SheetTransaction.count') do
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
                        "#{variables(:date).id}" => { month: '05', day: '28', year: '2012' },
                        "#{variables(:file).id}" => { response_file: '' },
                        "#{variables(:time).id}" => { hour: '14', minutes: '30', seconds: '00' },
                        "#{variables(:calculated).id}" => '1234'
                      }
      end
    end

    assert_not_nil assigns(:sheet)
    assert_equal 11, assigns(:sheet).variables.size

    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test "should create sheet and lock sheet" do
    assert_difference('Sheet.count') do
      post :create, project_id: @project, sheet: { design_id: designs(:all_variable_types), locked: '1' },
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
                      "#{variables(:date).id}" => { month: '05', day: '28', year: '2012' },
                      "#{variables(:file).id}" => { response_file: '' },
                      "#{variables(:time).id}" => { hour: '14', minutes: '30', seconds: '00' },
                      "#{variables(:calculated).id}" => '1234'
                    }
    end

    assert_not_nil assigns(:sheet)
    assert_equal 11, assigns(:sheet).variables.size
    assert_equal true, assigns(:sheet).locked
    assert_not_nil assigns(:sheet).first_locked_at
    assert_equal users(:valid).id, assigns(:sheet).first_locked_by_id

    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  # TODO, rewrite these for subject_events
  # test "should create sheet with subject schedule and event" do
  #   assert_difference('Sheet.count') do
  #     post :create, project_id: @project, sheet: { design_id: designs(:all_variable_types), subject_schedule_id: subject_schedules(:one).id, event_id: events(:one).id },
  #                   subject_code: subjects(:two).subject_code,
  #                   site_id: subjects(:two).site_id,
  #                   variables: { }
  #   end

  #   assert_not_nil assigns(:sheet)
  #   assert_not_nil assigns(:sheet).event
  #   assert_not_nil assigns(:sheet).subject_schedule

  #   assert_redirected_to project_subject_path(assigns(:sheet).subject.project, assigns(:sheet).subject)
  # end

  # TODO, rewrite these for subject_events
  # test "should create sheet with and remove subject schedule and event if the subject is changed" do
  #   assert_difference('Sheet.count') do
  #     post :create, project_id: @project, sheet: { design_id: designs(:all_variable_types), subject_schedule_id: subject_schedules(:one).id, event_id: events(:one).id },
  #                   subject_code: subjects(:one).subject_code,
  #                   site_id: subjects(:one).site_id,
  #                   variables: { }
  #   end

  #   assert_not_nil assigns(:sheet)
  #   assert_nil assigns(:sheet).subject_schedule
  #   assert_nil assigns(:sheet).event

  #   assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  # end

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
                      "#{variables(:date).id}" => { month: '05', day: '28', year: '2012' },
                      "#{variables(:file).id}" => { response_file: '' },
                      "#{variables(:time).id}" => { hour: '14', minutes: '30', seconds: '00' },
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

  test "should create new validated subject and strip whitespace" do
    assert_difference('Subject.count') do
      assert_difference('Sheet.count') do
        post :create, project_id: @project, sheet: { design_id: designs(:all_variable_types) }, subject_code: ' A600 ', site_id: sites(:valid_range).id
      end
    end

    assert_not_nil assigns(:sheet)
    assert_equal Subject.last, assigns(:sheet).subject
    assert_equal 'valid', assigns(:sheet).subject.status
    assert_equal 'A600', assigns(:sheet).subject.subject_code

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

  test "should not create sheet for site viewer" do
    login(users(:site_one_viewer))
    assert_difference('Sheet.count', 0) do
      post :create, project_id: @project, sheet: { design_id: @sheet.design_id },
                    subject_code: 'Code01',
                    site_id: sites(:one).id
    end

    assert_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to root_path
  end

  test "should create sheet for site editor" do
    login(users(:site_one_editor))
    assert_difference('Sheet.count') do
      post :create, project_id: @project, sheet: { design_id: @sheet.design_id },
                    subject_code: 'Code01',
                    site_id: sites(:one).id
    end

    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test "should not create sheet for site editor for another site" do
    login(users(:site_one_editor))
    assert_difference('Sheet.count', 0) do
      post :create, project_id: @project, sheet: { design_id: @sheet.design_id },
                    subject_code: 'S2Code001',
                    site_id: sites(:two).id
    end

    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_equal ["can't be blank"], assigns(:sheet).errors[:subject_id]
    assert_template 'new'
    assert_response :success
  end

  test "should create sheet and reassign subject to another site on the project" do
    assert_difference('Subject.count', 0) do
      assert_difference('Sheet.count') do
        post :create, project_id: @project, sheet: { design_id: @sheet.design_id },
                      subject_code: 'Code01',
                      site_id: sites(:three).id
      end
    end

    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)

    assert_equal sites(:three).id, assigns(:sheet).subject.site_id

    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test "should not create sheet for site editor for subject that already exists on another site" do
    login(users(:site_one_editor))
    assert_difference('Sheet.count', 0) do
      post :create, project_id: @project, sheet: { design_id: @sheet.design_id },
                    subject_code: 'S2001',
                    site_id: sites(:one).id
    end

    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_equal ["can't be blank"], assigns(:sheet).errors[:subject_id]
    assert_template 'new'
    assert_response :success
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

  test "should show sheet to site viewer" do
    login(users(:site_one_viewer))
    get :show, id: @sheet, project_id: @project
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test "should show sheet with ajax" do
    xhr :get, :show, id: @sheet, project_id: @project, format: 'js'
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:project)
    assert_template 'show'
    assert_response :success
  end

  test "should show sheet with ajax with all variables" do
    xhr :get, :show, id: sheets(:all_variables), project_id: sheets(:all_variables).project_id, format: 'js'
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:project)
    assert_template 'show'
    assert_response :success
  end

  test "should show sheet with grid responses" do
    xhr :get, :show, id: sheets(:has_grid), project_id: @project, format: 'js'
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:project)
    assert_template 'show'
    assert_response :success
  end

  test "should show sheet with attached file" do
    xhr :get, :show, id: sheets(:file_attached), project_id: @project, format: 'js'
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:project)
    assert_template 'show'
    assert_response :success
  end

  test "should submit public survey" do
    assert_difference('SheetTransaction.count') do
      assert_difference('Subject.count') do
        assert_difference('Sheet.count') do
          post :submit_public_survey, id: designs(:admin_public_design), project_id: designs(:admin_public_design).project, email: 'test@example.com'
        end
      end
    end

    assert_not_nil assigns(:design)
    assert_equal true, assigns(:design).publicly_available
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_equal 'test@example.com', assigns(:subject).email
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:sheet).authentication_token

    assert_redirected_to about_survey_path(project_id: assigns(:project).id, sheet_id: assigns(:sheet).id, sheet_authentication_token: assigns(:sheet).authentication_token)
  end

  test "should submit public survey and redirect to redirect_url" do
    assert_difference('Subject.count') do
      assert_difference('Sheet.count') do
        post :submit_public_survey, id: designs(:admin_public_design_with_redirect), project_id: designs(:admin_public_design).project, email: 'test@example.com'
      end
    end

    assert_not_nil assigns(:design)
    assert_equal true, assigns(:design).publicly_available
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:subject)
    assert_equal 'test@example.com', assigns(:subject).email
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:sheet).authentication_token

    assert_redirected_to 'http://localhost/survey_completed'
  end

  test "should submit public survey without selecting a site" do
    assert_difference('SheetTransaction.count') do
      assert_difference('Subject.count') do
        assert_difference('Sheet.count') do
          post :submit_public_survey, id: designs(:admin_public_design), project_id: designs(:admin_public_design).project, email: 'test@example.com', site_id: ''
        end
      end
    end

    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:sheet).subject
    assert_equal sites(:admin_site).id, assigns(:sheet).subject.site_id

    assert_redirected_to about_survey_path(project_id: assigns(:project).id, sheet_id: assigns(:sheet).id, sheet_authentication_token: assigns(:sheet).authentication_token)
  end

  test "should submit public survey with first site selected" do
    assert_difference('SheetTransaction.count') do
      assert_difference('Subject.count') do
        assert_difference('Sheet.count') do
          post :submit_public_survey, id: designs(:admin_public_design), project_id: designs(:admin_public_design).project, email: 'test@example.com', site_id: sites(:admin_site).id
        end
      end
    end

    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:sheet).subject
    assert_equal sites(:admin_site).id, assigns(:sheet).subject.site_id

    assert_redirected_to about_survey_path(project_id: assigns(:project).id, sheet_id: assigns(:sheet).id, sheet_authentication_token: assigns(:sheet).authentication_token)
  end

  test "should submit public survey with second site selected" do
    assert_difference('SheetTransaction.count') do
      assert_difference('Subject.count') do
        assert_difference('Sheet.count') do
          post :submit_public_survey, id: designs(:admin_public_design), project_id: designs(:admin_public_design).project, email: 'test@example.com', site_id: sites(:admin_site_two).id
        end
      end
    end

    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:sheet).subject
    assert_equal sites(:admin_site_two).id, assigns(:sheet).subject.site_id

    assert_redirected_to about_survey_path(project_id: assigns(:project).id, sheet_id: assigns(:sheet).id, sheet_authentication_token: assigns(:sheet).authentication_token)
  end


  test "should not submit private survey" do
    assert_difference('SheetTransaction.count', 0) do
      assert_difference('Subject.count', 0) do
        assert_difference('Sheet.count', 0) do
          post :submit_public_survey, id: designs(:admin_design), project_id: designs(:admin_design).project
        end
      end
    end

    assert_not_nil assigns(:design)
    assert_equal false, assigns(:design).publicly_available
    assert_not_nil assigns(:project)
    assert_nil assigns(:subject)
    assert_nil assigns(:sheet)

    assert_equal "This survey no longer exists.", flash[:alert]
    assert_redirected_to about_survey_path
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
    assert_equal "Survey has been locked.", flash[:alert]
    assert_redirected_to new_user_session_path
  end

  test "should submit sheet survey using authentication_token" do
    post :submit_survey, id: sheets(:external), project_id: sheets(:external).project, sheet_authentication_token: sheets(:external).authentication_token
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_redirected_to about_survey_path(project_id: sheets(:external).project_id, sheet_id: sheets(:external).id, sheet_authentication_token: sheets(:external).authentication_token)
  end

  test "should not submit sheet survey using invalid authentication_token" do
    post :submit_survey, id: sheets(:external), project_id: sheets(:external).project, sheet_authentication_token: '123'
    assert_not_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_equal "Survey has been locked.", flash[:alert]
    assert_redirected_to new_user_session_path
  end

  test "should show sheet transactions" do
    get :transactions, id: @sheet, project_id: @project
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:project)
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

  test "should not show transactions for invalid sheet" do
    get :transactions, id: -1, project_id: @project
    assert_not_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to project_sheets_path(@project)
  end

  test "should not show transactions for invalid project" do
    get :transactions, id: @sheet, project_id: -1
    assert_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to root_path
  end

  test "should not show sheet for user from different site" do
    login(users(:site_one_viewer))
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

  test "should print sheet on project that hides values" do
    get :print, id: sheets(:two), project_id: projects(:two)
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

  test "should get edit for site editor" do
    login(users(:site_one_editor))
    get :edit, id: @sheet, project_id: @project
    assert_response :success
  end

  test "should not get edit for site viewer" do
    login(users(:site_one_viewer))
    get :edit, id: @sheet, project_id: @project
    assert_redirected_to root_path
  end

  test "should not get edit for locked sheet" do
    get :edit, id: sheets(:locked), project_id: @project

    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test "should update sheet" do
    assert_difference('SheetTransaction.count') do
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
                      "#{variables(:date).id}" => { month: '05', day: '29', year: '2012' },
                      "#{variables(:file).id}" => { response_file: '' }
                    }
    end

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
                      "#{variables(:date).id}" => { month: '05', day: '29', year: '2012' },
                      "#{variables(:file).id}" => { response_file: '' }
                    }

    assert_not_nil assigns(:sheet)
    assert_equal 9, assigns(:sheet).variables.size
    assert_redirected_to new_project_sheet_path(assigns(:sheet).project, sheet: { design_id: assigns(:sheet).design_id })
  end

  test "should update sheet with grid" do
    put :update, id: sheets(:has_grid), project_id: sheets(:has_grid).project_id, sheet: { design_id: designs(:has_grid) },
                  subject_code: sheets(:has_grid).subject.subject_code,
                  site_id: sheets(:has_grid).subject.site_id,
                  variables: {
                    "#{variables(:grid).id}" => { "0" => {  "#{variables(:change_options).id}" => "1",
                                                            "#{variables(:file).id}" => { response_file: { cache: '' } },
                                                            "#{variables(:checkbox).id}" => ['acct101', 'econ101'],
                                                            "#{variables(:height).id}" => '1.5',
                                                            "#{variables(:weight).id}" => '70.0',
                                                            "#{variables(:calculated).id}" => '31.11',
                                                            "#{variables(:integer).id}" => '25',
                                                            "#{variables(:time).id}" => { hour: '11', minutes: '30', seconds: '59' }
                                                          },
                                                  "1" => {  "#{variables(:change_options).id}" => "2",
                                                            "#{variables(:file).id}" => { response_file: { cache: '' } },
                                                            "#{variables(:checkbox).id}" => ['econ101'],
                                                            "#{variables(:height).id}" => '1.5',
                                                            "#{variables(:weight).id}" => '0.0',
                                                            "#{variables(:calculated).id}" => '',
                                                            "#{variables(:integer).id}" => '25',
                                                            "#{variables(:time).id}" => { hour: '13', minutes: '20', seconds: '01' }
                                                          },
                                                  "2" => {  "#{variables(:change_options).id}" => "3",
                                                            "#{variables(:file).id}" => { response_file: { cache: '' } },
                                                            "#{variables(:checkbox).id}" => [],
                                                            "#{variables(:height).id}" => '1.5',
                                                            "#{variables(:weight).id}" => '70.0',
                                                            "#{variables(:calculated).id}" => '31.11',
                                                            "#{variables(:integer).id}" => '25',
                                                            "#{variables(:time).id}" => { hour: '14', minutes: '56', seconds: '33' }
                                                          }
                                                }
                             }

    assert_not_nil assigns(:sheet)
    assert_equal 1, assigns(:sheet).variables.size
    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test "should update sheet with grid and remove top grid row" do
    put :update, id: sheets(:has_grid), project_id: sheets(:has_grid).project_id, sheet: { design_id: designs(:has_grid) },
                  subject_code: sheets(:has_grid).subject.subject_code,
                  site_id: sheets(:has_grid).subject.site_id,
                  variables: {
                    "#{variables(:grid).id}" => { "1" => {  "#{variables(:change_options).id}" => "2",
                                                            "#{variables(:file).id}" => { response_file: { cache: '' } },
                                                            "#{variables(:checkbox).id}" => ['econ101'],
                                                            "#{variables(:height).id}" => '1.5',
                                                            "#{variables(:weight).id}" => '0.0',
                                                            "#{variables(:calculated).id}" => '',
                                                            "#{variables(:integer).id}" => '25',
                                                            "#{variables(:time).id}" => { hour: '13', minutes: '20', seconds: '01' }
                                                          },
                                                  "2" => {  "#{variables(:change_options).id}" => "3",
                                                            "#{variables(:file).id}" => { response_file: fixture_file_upload('../../test/support/projects/rails.png') },
                                                            "#{variables(:checkbox).id}" => [],
                                                            "#{variables(:height).id}" => '1.5',
                                                            "#{variables(:weight).id}" => '70.0',
                                                            "#{variables(:calculated).id}" => '31.11',
                                                            "#{variables(:integer).id}" => '25',
                                                            "#{variables(:time).id}" => { hour: '14', minutes: '56', seconds: '33' }
                                                          }
                                                }
                              }

    assert_not_nil assigns(:sheet)
    assert_equal 1, assigns(:sheet).variables.size
    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test "should not update sheet with blank subject code" do
    put :update, id: @sheet, project_id: @project, sheet: { design_id: designs(:all_variable_types) }, subject_code: '', site_id: @sheet.subject.site_id, variables: { }

    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)

    assert assigns(:sheet).errors.size > 0
    assert_equal ["can't be blank"], assigns(:sheet).errors[:subject_id]
    assert_template 'edit'
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

  test "should update and lock sheet" do
    put :update, id: @sheet, project_id: @project, sheet: { design_id: designs(:all_variable_types), locked: '1' }, subject_code: @sheet.subject.subject_code, site_id: @sheet.subject.site_id, variables: { }
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)

    assert_equal true, assigns(:sheet).locked
    assert_not_nil assigns(:sheet).first_locked_at
    assert_equal users(:valid).id, assigns(:sheet).first_locked_by_id

    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test "should not update locked sheet" do
    put :update, id: sheets(:locked), project_id: @project, sheet: { locked: '0' }, subject_code: @sheet.subject.subject_code, site_id: @sheet.subject.site_id, variables: { }
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)

    assert_equal true, assigns(:sheet).locked

    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test "should get transfer sheet for editor" do
    get :transfer, project_id: @project, id: @sheet

    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)

    assert_response :success
  end

  test "should not get transfer sheet for viewer" do
    login(users(:site_one_viewer))
    get :transfer, project_id: @project, id: @sheet
    assert_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to root_path
  end

  test "should not get transfer sheet for locked sheet" do
    get :transfer, project_id: @project, id: sheets(:locked)
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_redirected_to [assigns(:project), assigns(:sheet)]
  end

  test "should transfer sheet to new subject for editor" do
    patch :transfer, project_id: @project, id: @sheet, subject_id: subjects(:two)

    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)

    assert_equal subjects(:two).id, assigns(:sheet).subject_id
    assert_equal nil, assigns(:sheet).subject_event_id
    assert_equal users(:valid).id, assigns(:sheet).last_user_id
    assert_not_nil assigns(:sheet).last_edited_at

    assert_redirected_to [assigns(:project), assigns(:sheet)]
  end

  test "should undo transfer for subject for editor" do
    patch :transfer, project_id: @project, id: @sheet, subject_id: subjects(:two), undo: '1'

    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)

    assert_equal subjects(:two).id, assigns(:sheet).subject_id
    assert_equal nil, assigns(:sheet).subject_event_id
    assert_equal users(:valid).id, assigns(:sheet).last_user_id
    assert_not_nil assigns(:sheet).last_edited_at

    assert_redirected_to [assigns(:project), assigns(:sheet)]
  end

  test "should not make changes if transfer does not provide a new subject" do
    patch :transfer, project_id: @project, id: @sheet, subject_id: subjects(:one)

    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)

    assert_redirected_to [assigns(:project), assigns(:sheet)]
  end

  test "should not transfer sheet to new subject for viewer" do
    login(users(:site_one_viewer))
    patch :transfer, project_id: @project, id: @sheet, subject_id: subjects(:two)

    assert_nil assigns(:project)
    assert_nil assigns(:sheet)

    assert_redirected_to root_path
  end

  test "should move sheet to subject event for editor" do
    patch :move_to_event, project_id: @project, id: @sheet, subject_event_id: subject_events(:one), format: 'js'

    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)

    assert_equal subject_events(:one).id, assigns(:sheet).subject_event_id
    assert_equal users(:valid).id, assigns(:sheet).last_user_id
    assert_not_nil assigns(:sheet).last_edited_at
    assert_not_nil assigns(:subject)

    assert_template 'move_to_event'
  end

  test "should not make changes if move_to_event does not provide a new subject" do
    patch :move_to_event, project_id: @project, id: @sheet, format: 'js'

    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)

    assert_response :success
  end

  test "should not move sheet to subject event for viewer" do
    login(users(:site_one_viewer))
    patch :move_to_event, project_id: @project, id: @sheet, subject_event_id: subject_events(:one), format: 'js'

    assert_nil assigns(:project)
    assert_nil assigns(:sheet)

    assert_response :success
  end

  test "should destroy sheet" do
    assert_difference('Sheet.current.count', -1) do
      delete :destroy, id: @sheet, project_id: @project
    end

    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)

    assert_redirected_to project_subject_path(@project, @sheet.subject)
  end

  test "should not destroy sheet with invalid project" do
    assert_difference('Sheet.current.count', 0) do
      delete :destroy, id: @sheet, project_id: -1
    end

    assert_nil assigns(:project)
    assert_nil assigns(:sheet)

    assert_redirected_to root_path
  end

  test "should not destroy locked sheet" do
    assert_difference('Sheet.current.count', 0) do
      delete :destroy, id: sheets(:locked), project_id: @project
    end

    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)

    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test "should unlock sheet" do
    assert_difference('SheetTransaction.count') do
      post :unlock, id: sheets(:locked), project_id: @project
    end

    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)

    assert_equal false, assigns(:sheet).locked
    assert_not_nil assigns(:sheet).first_locked_at
    assert_equal users(:valid).id, assigns(:sheet).first_locked_by_id

    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test "should not lock sheet on project that does not have lockable and unlockable enabled" do
    login(users(:admin))
    put :update, id: sheets(:external), project_id: projects(:three), sheet: { locked: '1' }, subject_code: sheets(:external).subject.subject_code, site_id: sheets(:external).subject.site_id, variables: { }

    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)

    assert_equal false, assigns(:sheet).locked

    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test "should not unlock sheet on project that does not have lockable and unlockable enabled" do
    login(users(:admin))
    post :unlock, id: sheets(:locked_on_non_lockable_project), project_id: projects(:three)
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)

    assert_equal true, assigns(:sheet).locked

    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end
end
