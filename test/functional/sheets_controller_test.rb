require 'test_helper'

class SheetsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @sheet = sheets(:one)
  end

  test "should get csv" do
    get :index, format: 'csv'
    assert_not_nil assigns(:csv_string)
    assert_not_nil assigns(:sheet_count)
    assert_response :success
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

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sheet" do
    assert_difference('Sheet.count') do
      post :create, sheet: { description: @sheet.description, design_id: designs(:all_variable_types), name: 'All Variable Types', project_id: @sheet.project_id, study_date: '05/23/2012' },
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
                      "#{variables(:file).id}" => ''
                    }
    end

    assert_not_nil assigns(:sheet)
    assert_equal 9, assigns(:sheet).variables.size

    assert_redirected_to sheet_path(assigns(:sheet))
  end

  test "should create new subject for different project" do
    assert_difference('Subject.count') do
      assert_difference('Sheet.count') do
        post :create, sheet: { description: @sheet.description, design_id: designs(:all_variable_types), name: 'All Variable Types', project_id: sheets(:two).project_id, study_date: '05/23/2012' }, subject_code: 'Code01', site_id: sites(:two).id
      end
    end

    assert_not_nil assigns(:sheet)
    assert_equal Subject.last, assigns(:sheet).subject

    assert_redirected_to sheet_path(assigns(:sheet))
  end

  test "should not create sheet on same design project subject study_date" do
    assert_difference('Sheet.count', 0) do
      post :create, sheet: { description: @sheet.description, design_id: @sheet.design_id, name: @sheet.name, project_id: @sheet.project_id, study_date: '05/21/2012' },
                    subject_code: 'Code01',
                    site_id: @sheet.subject.site_id
    end

    assert_not_nil assigns(:sheet)
    assert_equal ['has already been taken'], assigns(:sheet).errors[:study_date]
    assert_template 'new'
    assert_response :success
  end

  test "should not create sheet on invalid project" do
    assert_difference('Sheet.count', 0) do
      post :create, sheet: { description: @sheet.description, design_id: @sheet.design_id, name: @sheet.name, project_id: projects(:four), study_date: '05/21/2012' },
                    subject_code: 'Code01',
                    site_id: @sheet.subject.site_id
    end

    assert_not_nil assigns(:sheet)
    assert_equal ["can't be blank"], assigns(:sheet).errors[:project_id]
    assert_template 'new'
    assert_response :success
  end

  test "should show sheet" do
    get :show, id: @sheet
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sheet
    assert_response :success
  end

  test "should update sheet" do
    put :update, id: @sheet, sheet: { description: @sheet.description, design_id: designs(:all_variable_types), name: 'All Variable Types', project_id: @sheet.project_id, study_date: '05/23/2012' },
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
                      "#{variables(:file).id}" => ''
                    }

    assert_not_nil assigns(:sheet)
    assert_equal 9, assigns(:sheet).variables.size
    assert_redirected_to sheet_path(assigns(:sheet))
  end

  test "should destroy sheet" do
    assert_difference('Sheet.current.count', -1) do
      delete :destroy, id: @sheet
    end

    assert_redirected_to sheets_path
  end
end
