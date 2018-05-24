# frozen_string_literal: true

require 'test_helper'

# Test to make sure that project and site editors can modify sheets.
class SheetsControllerTest < ActionController::TestCase
  setup do
    login(users(:regular))
    @sheet = sheets(:one)
    @project = projects(:one)
  end

  test 'should get index' do
    get :index, params: { project_id: @project }
    assert_not_nil assigns(:sheets)
    assert_response :success
  end

  test 'should search for sheets by date' do
    get :index, params: { project_id: @project, search: 'created:2016-11-04' }
    assert_not_nil assigns(:sheets)
    assert_response :success
  end

  test 'should search for sheets with invalid date' do
    get :index, params: { project_id: @project, search: 'created:2016-02-30' }
    assert_not_nil assigns(:sheets)
    assert_response :success
  end

  test 'should search for sheets by less than date' do
    get :index, params: { project_id: @project, search: 'created:<2016-11-04' }
    assert_not_nil assigns(:sheets)
    assert_response :success
  end

  test 'should search for sheets by greater than date' do
    get :index, params: { project_id: @project, search: 'created:>2016-11-04' }
    assert_not_nil assigns(:sheets)
    assert_response :success
  end

  test 'should search for sheets by less than or equal to date' do
    get :index, params: { project_id: @project, search: 'created:<=2016-11-04' }
    assert_not_nil assigns(:sheets)
    assert_response :success
  end

  test 'should search for sheets by greater than or equal to date' do
    get :index, params: { project_id: @project, search: 'created:>=2016-11-04' }
    assert_not_nil assigns(:sheets)
    assert_response :success
  end

  test 'should search for sheets by variable' do
    get :index, params: { project_id: @project, search: 'var_1:1' }
    assert_not_nil assigns(:sheets)
    assert_response :success
  end

  test 'should search for sheets by non-existent variable' do
    get :index, params: { project_id: @project, search: 'var_does_not_exist:any' }
    assert_not_nil assigns(:sheets)
    assert_response :success
  end

  test 'should search for sheets with comments' do
    get :index, params: { project_id: @project, search: 'has:comments' }
    assert_not_nil assigns(:sheets)
    assert_response :success
  end

  test 'should search for sheets with adverse events' do
    get :index, params: { project_id: @project, search: 'has:adverse-events' }
    assert_not_nil assigns(:sheets)
    assert_response :success
  end

  test 'should search for sheets with files' do
    get :index, params: { project_id: @project, search: 'has:files' }
    assert_not_nil assigns(:sheets)
    assert_response :success
  end

  test 'should search for sheets that fail checks' do
    get :index, params: { project_id: @project, search: 'checks:any' }
    assert_not_nil assigns(:sheets)
    assert_response :success
  end

  test 'should search for sheets that are on an event' do
    get :index, params: { project_id: @project, search: 'events:any' }
    assert_not_nil assigns(:sheets)
    assert_response :success
  end

  test 'should search for sheets that are not on an event' do
    get :index, params: { project_id: @project, search: 'events:missing' }
    assert_not_nil assigns(:sheets)
    assert_response :success
  end

  test 'should search for sheets that have coverage computed' do
    get :index, params: { project_id: @project, search: 'coverage:any' }
    assert_not_nil assigns(:sheets)
    assert_response :success
  end

  test 'should search for sheets that do not have coverage computed' do
    get :index, params: { project_id: @project, search: 'coverage:missing' }
    assert_not_nil assigns(:sheets)
    assert_response :success
  end

  test 'should search for sheets that do have coverage greater than 80 percent' do
    get :index, params: { project_id: @project, search: 'coverage:>80' }
    assert_not_nil assigns(:sheets)
    assert_response :success
  end

  test 'should search for sheets that do have coverage that is not an integer' do
    get :index, params: { project_id: @project, search: 'coverage:a' }
    assert_not_nil assigns(:sheets)
    assert_response :success
  end

  test 'should search for sheets for randomized subjects' do
    get :index, params: { project_id: @project, search: 'is:randomized' }
    assert_not_nil assigns(:sheets)
    assert_response :success
  end

  test 'should search for sheets for un-randomized subjects' do
    get :index, params: { project_id: @project, search: 'not:randomized' }
    assert_not_nil assigns(:sheets)
    assert_response :success
  end

  test 'should get index with invalid project' do
    get :index, params: { project_id: -1 }
    assert_nil assigns(:sheets)
    assert_redirected_to root_path
  end

  test 'should get paginated index' do
    get :index, params: { project_id: @project, page: 2 }
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test 'should get paginated index order by site' do
    get :index, params: { project_id: @project, order: 'site' }
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test 'should get paginated index order by site descending' do
    get :index, params: { project_id: @project, order: 'site desc' }
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test 'should get index by design' do
    get :index, params: { project_id: @project, order: 'design' }
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test 'should get index by design desc' do
    get :index, params: {
      project_id: @project, order: 'design desc'
    }
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test 'should get index by subject' do
    get :index, params: { project_id: @project, order: 'subject' }
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test 'should get index by subject desc' do
    get :index, params: {
      project_id: @project, order: 'subject desc'
    }
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test 'should get index by percent' do
    get :index, params: { project_id: @project, order: 'percent' }
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test 'should get index by percent desc' do
    get :index, params: {
      project_id: @project, order: 'percent desc'
    }
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test 'should get index by created by' do
    get :index, params: { project_id: @project, order: 'created_by' }
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test 'should get index by created by desc' do
    get :index, params: { project_id: @project, order: 'created_by desc' }
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test 'should get index by created' do
    get :index, params: { project_id: @project, order: 'created' }
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test 'should get index by created desc' do
    get :index, params: { project_id: @project, order: 'created desc' }
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test 'should get index by edited' do
    get :index, params: { project_id: @project, order: 'edited' }
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test 'should get index by edited desc' do
    get :index, params: { project_id: @project, order: 'edited desc' }
    assert_not_nil assigns(:sheets)
    assert_template 'index'
  end

  test 'should get attached file' do
    assert_not_equal 0, sheet_variables(:file_attachment).response_file.size
    get :file, params: {
      id: sheets(:file_attached), project_id: @project,
      sheet_variable_id: sheet_variables(:file_attachment),
      variable_id: variables(:file), position: nil
    }
    assert_not_nil response
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:sheet_variable)
    assert_not_nil assigns(:object)
    assert_kind_of String, response.body
    assert_equal(
      File.binread(File.join(CarrierWave::Uploader::Base.root, assigns(:object).response_file.url)),
      response.body
    )
  end

  test 'should get attached file in grid' do
    assert_not_equal 0, grids(:has_grid_row_one_attached_file).response_file.size
    get :file, params: {
      id: sheets(:has_grid_with_file), project_id: @project,
      sheet_variable_id: sheet_variables(:has_grid_with_file),
      variable_id: variables(:file), position: 0
    }

    assert_not_nil response
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:sheet_variable)
    assert_not_nil assigns(:object)

    assert_kind_of String, response.body
    assert_equal(
      File.binread(File.join(CarrierWave::Uploader::Base.root, assigns(:object).response_file.url)),
      response.body
    )
  end

  test 'should not get non-existent file in grid' do
    assert_equal 0, grids(:has_grid_row_two_no_attached_file).response_file.size
    get :file, params: {
      id: sheets(:has_grid_with_file), project_id: @project,
      sheet_variable_id: sheet_variables(:has_grid_with_file),
      variable_id: variables(:file), position: 1
    }

    assert_not_nil response
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:sheet_variable)
    assert_not_nil assigns(:object)
    assert_equal 0, assigns(:object).response_file.size

    assert_response :success
  end

  test 'should not get attached file for viewer on different site' do
    login(users(:site_one_viewer))
    assert_not_equal 0, sheet_variables(:file_attachment).response_file.size
    get :file, params: {
      id: sheets(:file_attached), project_id: @project,
      sheet_variable_id: sheet_variables(:file_attachment),
      variable_id: variables(:file), position: nil
    }

    assert_not_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_nil assigns(:variable)
    assert_nil assigns(:sheet_variable)

    assert_redirected_to project_sheets_path(assigns(:project))
  end

  test 'should get new and redirect' do
    get :new, params: { project_id: @project }
    assert_redirected_to assigns(:project)
  end

  test 'should create sheet' do
    assert_difference('SheetTransaction.count') do
      assert_difference('Sheet.count') do
        post :create, params: {
          project_id: @project,
          subject_id: @sheet.subject,
          sheet: { design_id: designs(:all_variable_types).id },
          variables: {
            variables(:dropdown).id.to_s => 'm',
            variables(:checkbox).id.to_s => %w(acct101 econ101),
            variables(:radio).id.to_s => '2',
            variables(:string).id.to_s => 'This is a string',
            variables(:text).id.to_s => 'Lorem ipsum dolor sit amet, consectetu\
r adipisicing elit, sed do eiusmod tempor incididunt ut labore et d\olore magna\
 aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nis\
i ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in\
 voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint oc\
caecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim i\
d est laborum.',
            variables(:integer).id.to_s => 30,
            variables(:numeric).id.to_s => 180.5,
            variables(:date).id.to_s => {
              month: '05', day: '28', year: '2012'
            },
            variables(:file).id.to_s => { response_file: '' },
            variables(:time_of_day).id.to_s => {
              hours: '14', minutes: '30', seconds: '00'
            },
            variables(:calculated).id.to_s => '1234'
          }
        }
      end
    end
    assert_not_nil assigns(:sheet)
    assert_equal 11, assigns(:sheet).variables.size
    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test 'should create sheet with large integer' do
    assert_difference('SheetTransaction.count') do
      assert_difference('Sheet.count') do
        post :create, params: {
          project_id: @project,
          subject_id: @sheet.subject,
          sheet: { design_id: designs(:has_no_validations).id },
          variables: {
            variables(:integer_no_range).id.to_s => 127_858_751_212_122_128_384
          }
        }
      end
    end

    assert_not_nil assigns(:sheet)
    assigns(:sheet).sheet_variables.reload
    assert_equal 127_858_751_212_122_128_384, assigns(:sheet).sheet_variables.first.get_response(:raw)

    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test 'should create sheet and save date to correct database format' do
    assert_difference('SheetTransaction.count') do
      assert_difference('Sheet.count') do
        post :create, params: {
          project_id: @project,
          subject_id: @sheet.subject,
          sheet: { design_id: designs(:has_no_validations).id },
          variables: {
            variables(:date_no_range).id.to_s => {
              month: '5', day: '2', year: '1992'
            }
          }
        }
      end
    end

    assert_not_nil assigns(:sheet)
    assigns(:sheet).sheet_variables.reload
    assert_equal '1992-05-02', assigns(:sheet).sheet_variables.first.get_response(:raw)

    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test 'should create sheet and save time of day to correct database format' do
    assert_difference('SheetTransaction.count') do
      assert_difference('Sheet.count') do
        post :create, params: {
          project_id: @project,
          subject_id: @sheet.subject,
          sheet: { design_id: designs(:has_no_validations).id },
          variables: {
            variables(:time_of_day_no_range).id.to_s => {
              hours: '13', minutes: '2', seconds: ''
            }
          }
        }
      end
    end
    assert_not_nil assigns(:sheet)
    assigns(:sheet).sheet_variables.reload
    assert_equal '46920', assigns(:sheet).sheet_variables.first.get_response(:raw)
    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  # TODO, rewrite these for subject_events
  # test 'should create sheet with subject schedule and event' do
  #   assert_difference('Sheet.count') do
  #     post :create, project_id: @project, sheet: { design_id: designs(:all_variable_types).id, subject_schedule_id: subject_schedules(:one).id, event_id: events(:one).id },
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
  # test 'should create sheet with and remove subject schedule and event if the subject is changed' do
  #   assert_difference('Sheet.count') do
  #     post :create, project_id: @project, sheet: { design_id: designs(:all_variable_types).id, subject_schedule_id: subject_schedules(:one).id, event_id: events(:one).id },
  #                   subject_code: subjects(:one).subject_code,
  #                   site_id: subjects(:one).site_id,
  #                   variables: { }
  #   end

  #   assert_not_nil assigns(:sheet)
  #   assert_nil assigns(:sheet).subject_schedule
  #   assert_nil assigns(:sheet).event

  #   assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  # end

  test "should create sheet with grid" do
    post :create, params: {
      project_id: @project,
      subject_id: sheets(:has_grid).subject,
      sheet: { design_id: designs(:has_grid).id },
      variables: {
        variables(:grid).id.to_s => {
          "-1" => { "-1" => "" },
          "13463487147483201" => { variables(:change_options).id.to_s => "1" },
          "1346351022118849"  => { variables(:change_options).id.to_s => "2" },
          "1346351034600475"  => { variables(:change_options).id.to_s => "3" }
        }
      }
    }
    assert_not_nil assigns(:sheet)
    assert_equal 1, assigns(:sheet).variables.size
    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test 'should not create sheet on invalid project' do
    assert_difference('Sheet.count', 0) do
      post :create, params: {
        project_id: projects(:four), subject_id: subjects(:one),
        sheet: { design_id: @sheet.design_id }
      }
    end

    assert_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to root_path
  end

  test 'should not create sheet without design' do
    assert_difference('Sheet.count', 0) do
      post :create, params: {
        project_id: @project, subject_id: subjects(:one),
        sheet: { design_id: '' }
      }
    end
    assert_template 'new'
    assert_response :success
  end

  test 'should not create sheet for site viewer' do
    login(users(:site_one_viewer))
    assert_difference('Sheet.count', 0) do
      post :create, params: {
        project_id: @project, subject_id: subjects(:one),
        sheet: { design_id: @sheet.design_id }
      }
    end

    assert_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to root_path
  end

  test 'should create sheet for site editor' do
    login(users(:site_one_editor))
    assert_difference('Sheet.count') do
      post :create, params: {
        project_id: @project, subject_id: subjects(:one),
        sheet: { design_id: @sheet.design_id }
      }
    end

    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test 'should show sheet' do
    get :show, params: { id: @sheet, project_id: @project }
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test 'should show sheet to site viewer' do
    login(users(:site_one_viewer))
    get :show, params: { id: @sheet, project_id: @project }
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test 'should show sheet with ajax' do
    get :show, params: { id: @sheet, project_id: @project }, xhr: true, format: 'js'
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:project)
    assert_template 'show'
    assert_response :success
  end

  test 'should show sheet with ajax with all variables' do
    get :show, params: {
      id: sheets(:all_variables),
      project_id: sheets(:all_variables).project_id
    }, xhr: true, format: 'js'
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:project)
    assert_template 'show'
    assert_response :success
  end

  test 'should show sheet with grid responses' do
    get :show, params: {
      id: sheets(:has_grid), project_id: @project
    }, xhr: true, format: 'js'
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:project)
    assert_template 'show'
    assert_response :success
  end

  test 'should show sheet with attached file' do
    get :show, params: {
      id: sheets(:file_attached), project_id: @project
    }, xhr: true, format: 'js'
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:project)
    assert_template 'show'
    assert_response :success
  end

  test 'should show sheet transactions' do
    get :transactions, params: { id: @sheet, project_id: @project }
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:project)
    assert_response :success
  end

  test 'should not show invalid sheet' do
    get :show, params: { id: -1, project_id: @project }
    assert_nil assigns(:sheet)
    assert_not_nil assigns(:project)
    assert_redirected_to project_sheets_path(@project)
  end

  test 'should not show sheet with invalid project' do
    get :show, params: { id: @sheet, project_id: -1 }
    assert_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to root_path
  end

  test 'should get sheet coverage' do
    post :coverage, params: { id: @sheet, project_id: @project }, format: 'js'
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:project)
    assert_template 'coverage'
    assert_response :success
  end

  test 'should not show transactions for invalid sheet' do
    get :transactions, params: { id: -1, project_id: @project }
    assert_not_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to project_sheets_path(@project)
  end

  test 'should not show transactions for invalid project' do
    get :transactions, params: { id: @sheet, project_id: -1 }
    assert_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to root_path
  end

  test 'should not show sheet for user from different site' do
    login(users(:site_one_viewer))
    get :show, params: { id: sheets(:three), project_id: @project }
    assert_not_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to project_sheets_path(assigns(:project))
  end

  test 'should print sheet' do
    skip if ENV['TRAVIS'] # Skip this test on Travis since Travis can't generate PDFs
    get :show, params: { project_id: @project, id: @sheet }, format: 'pdf'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_response :success
  end

  test 'should print sheet on project that hides values' do
    skip if ENV['TRAVIS'] # Skip this test on Travis since Travis can't generate PDFs
    get :show, params: { project_id: projects(:two), id: sheets(:two_a) }, format: 'pdf'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_response :success
  end

  test 'should not print invalid sheet' do
    skip if ENV['TRAVIS'] # Skip this test on Travis since Travis can't generate PDFs
    get :show, params: { project_id: @project, id: -1 }, format: 'pdf'
    assert_not_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to project_sheets_path(assigns(:project))
  end

  test 'should show sheet if PDF fails to render' do
    skip if ENV['TRAVIS'] # Skip this test on Travis since Travis can't generate PDFs
    begin
      original_latex = ENV['latex_location']
      ENV['latex_location'] = "echo #{original_latex}"
      get :show, params: { project_id: @project, id: sheets(:three) }, format: 'pdf'
      assert_not_nil assigns(:project)
      assert_not_nil assigns(:sheet)
      assert_redirected_to [@project, sheets(:three)]
    ensure
      ENV['latex_location'] = original_latex
    end
  end

  test 'should get edit' do
    get :edit, params: { id: @sheet, project_id: @project }
    assert_response :success
  end

  test 'should get edit for site editor' do
    login(users(:site_one_editor))
    get :edit, params: { id: @sheet, project_id: @project }
    assert_response :success
  end

  test 'should not get edit for site viewer' do
    login(users(:site_one_viewer))
    get :edit, params: { id: @sheet, project_id: @project }
    assert_redirected_to root_path
  end

  test 'should not get edit for auto-locked sheet' do
    login(users(:regular))
    get :edit, params: {
      project_id: projects(:auto_lock), id: sheets(:auto_lock)
    }

    assert_redirected_to [projects(:auto_lock), sheets(:auto_lock)]
  end

  test 'should set sheet as not missing' do
    login(users(:regular))
    post :set_as_not_missing, params: {
      project_id: projects(:auto_lock), id: sheets(:missing)
    }, format: 'js'
    assert_equal true, assigns(:sheet).deleted?
    assert_template 'subject_event'
    assert_response :success
  end

  test 'should update sheet' do
    assert_difference('SheetTransaction.count') do
      patch :update, params: {
        id: @sheet, project_id: @project,
        sheet: { design_id: designs(:all_variable_types).id },
        variables: {
          variables(:dropdown).id.to_s => 'f',
          variables(:checkbox).id.to_s => nil,
          variables(:radio).id.to_s => '1',
          variables(:string).id.to_s => 'This is an updated string',
          variables(:text).id.to_s => 'Lorem ipsum dolor sit amet',
          variables(:integer).id.to_s => 31,
          variables(:numeric).id.to_s => 190.5,
          variables(:date).id.to_s => { month: '05', day: '29', year: '2012' },
          variables(:file).id.to_s => { response_file: fixture_file_upload('../../test/support/projects/rails.png') }
        }
      }
    end
    assert_not_nil assigns(:sheet)
    assert_equal 9, assigns(:sheet).variables.size
    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test "should update sheet with grid" do
    patch :update, params: {
      id: sheets(:has_grid), project_id: sheets(:has_grid).project_id,
      sheet: { design_id: designs(:has_grid).id },
      variables: {
        variables(:grid).id.to_s => {
          "-1" => { "-1" => "" },
          "0" => {
            variables(:change_options).id.to_s => "1",
            variables(:file).id.to_s => { response_file: "" },
            variables(:checkbox).id.to_s => ["acct101", "econ101"],
            variables(:height).id.to_s => "1.5",
            variables(:weight).id.to_s => "70.0",
            variables(:calculated).id.to_s => "31.11",
            variables(:integer).id.to_s => "25",
            variables(:time_of_day).id.to_s => { hours: "11", minutes: "30", seconds: "59" }
          },
          "1" => {
            variables(:change_options).id.to_s => "2",
            variables(:file).id.to_s => { response_file: "" },
            variables(:checkbox).id.to_s => ["econ101"],
            variables(:height).id.to_s => "1.5",
            variables(:weight).id.to_s => "0.0",
            variables(:calculated).id.to_s => "",
            variables(:integer).id.to_s => "25",
            variables(:time_of_day).id.to_s => { hours: "13", minutes: "20", seconds: "01" }
          },
          "2" => {
            variables(:change_options).id.to_s => "3",
            variables(:file).id.to_s => { response_file: "" },
            variables(:checkbox).id.to_s => [],
            variables(:height).id.to_s => "1.5",
            variables(:weight).id.to_s => "70.0",
            variables(:calculated).id.to_s => "31.11",
            variables(:integer).id.to_s => "25",
            variables(:time_of_day).id.to_s => { hours: "14", minutes: "56", seconds: "33" }
          }
        }
      }
    }
    assert_not_nil assigns(:sheet)
    assert_equal 1, assigns(:sheet).variables.size
    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test "should update sheet with grid and remove top grid row" do
    patch :update, params: {
      id: sheets(:has_grid), project_id: sheets(:has_grid).project_id,
      sheet: { design_id: designs(:has_grid).id },
      variables: {
        variables(:grid).id.to_s => {
          "-1" => { "-1" => "" },
          "1" => {
            variables(:change_options).id.to_s => "2",
            variables(:file).id.to_s => { response_file: "" },
            variables(:checkbox).id.to_s => ["econ101"],
            variables(:height).id.to_s => "1.5",
            variables(:weight).id.to_s => "0.0",
            variables(:calculated).id.to_s => "",
            variables(:integer).id.to_s => "25",
            variables(:time_of_day).id.to_s => { hours: "13", minutes: "20", seconds: "01" }
          },
          "2" => {
            variables(:change_options).id.to_s => "3",
            variables(:file).id.to_s => { response_file: fixture_file_upload("../../test/support/projects/rails.png") },
            variables(:checkbox).id.to_s => [],
            variables(:height).id.to_s => "1.5",
            variables(:weight).id.to_s => "70.0",
            variables(:calculated).id.to_s => "31.11",
            variables(:integer).id.to_s => "25",
            variables(:time_of_day).id.to_s => { hours: "14", minutes: "56", seconds: "33" }
          }
        }
      }
    }
    assert_not_nil assigns(:sheet)
    assert_equal 1, assigns(:sheet).variables.size
    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test "should update sheet with grid and remove all grid rows" do
    patch :update, params: {
      id: sheets(:has_grid), project_id: sheets(:has_grid).project_id,
      sheet: { design_id: designs(:has_grid).id },
      variables: {
        variables(:grid).id.to_s => {
          "-1" => { "-1" => "" }
        }
      }
    }
    assert_not_nil assigns(:sheet)
    assert_equal 1, assigns(:sheet).variables.size
    assert_equal 0, Grid.where(sheet_variable: assigns(:sheet).sheet_variables).count
    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end


  test 'should not update sheet with blank design' do
    patch :update, params: { project_id: @project, id: @sheet, sheet: { design_id: '' }, variables: {} }
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_template 'edit'
    assert_response :success
  end

  test 'should not update invalid sheet' do
    patch :update, params: { id: -1, project_id: @project, sheet: { design_id: designs(:all_variable_types).id }, variables: {} }
    assert_not_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to project_sheets_path(@project)
  end

  test 'should not update sheet with invalid project' do
    patch :update, params: { id: @sheet, project_id: -1, sheet: { design_id: designs(:all_variable_types).id }, variables: {} }
    assert_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to root_path
  end

  test 'should not update auto-locked sheet' do
    login(users(:regular))
    assert_difference('SheetVariable.count', 0) do
      patch :update, params: {
        project_id: projects(:auto_lock), id: sheets(:auto_lock),
        variables: {
          variables(:string_on_auto_lock).id.to_s => 'Updated string'
        }
      }
    end
    assert_equal 'This sheet is locked.', flash[:notice]
    assert_redirected_to [projects(:auto_lock), sheets(:auto_lock)]
  end

  test 'should unlock sheet as project editor' do
    login(users(:regular))
    assert_equal true, sheets(:auto_lock).auto_locked?
    post :unlock, params: {
      project_id: projects(:auto_lock), id: sheets(:auto_lock)
    }
    sheets(:auto_lock).reload
    assert_equal false, sheets(:auto_lock).auto_locked?
    assert_redirected_to [projects(:auto_lock), sheets(:auto_lock)]
  end

  test 'should not unlock sheet as site editor' do
    login(users(:auto_lock_site_one_editor))
    assert_equal true, sheets(:auto_lock).auto_locked?
    post :unlock, params: {
      project_id: projects(:auto_lock), id: sheets(:auto_lock)
    }
    sheets(:auto_lock).reload
    assert_equal true, sheets(:auto_lock).auto_locked?
    assert_redirected_to root_path
  end

  test 'should remove shareable link as editor' do
    login(users(:admin))
    assert_difference('Sheet.where(authentication_token: nil).count') do
      post :remove_shareable_link, params: { project_id: projects(:three), id: sheets(:external) }
    end
    assert_redirected_to [projects(:three), sheets(:external)]
  end

  test 'should get reassign sheet for editor' do
    get :reassign, params: { project_id: @project, id: @sheet }
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_response :success
  end

  test 'should not get reassign sheet for viewer' do
    login(users(:site_one_viewer))
    get :reassign, params: { project_id: @project, id: @sheet }
    assert_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to root_path
  end

  test 'should not get reassign sheet for auto-locked sheet' do
    login(users(:auto_lock_site_one_editor))
    get :reassign, params: { project_id: projects(:auto_lock), id: sheets(:auto_lock) }
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_redirected_to [projects(:auto_lock), sheets(:auto_lock)]
  end

  test 'should reassign sheet to new subject for editor' do
    patch :reassign, params: { project_id: @project, id: @sheet, subject_id: subjects(:two) }
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_equal subjects(:two).id, assigns(:sheet).subject_id
    assert_nil assigns(:sheet).subject_event_id
    assert_equal users(:regular).id, assigns(:sheet).last_user_id
    assert_not_nil assigns(:sheet).last_edited_at
    assert_redirected_to [assigns(:project), assigns(:sheet)]
  end

  test 'should undo reassign for subject for editor' do
    patch :reassign, params: { project_id: @project, id: @sheet, subject_id: subjects(:two), undo: '1' }
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_equal subjects(:two).id, assigns(:sheet).subject_id
    assert_nil assigns(:sheet).subject_event_id
    assert_equal users(:regular).id, assigns(:sheet).last_user_id
    assert_not_nil assigns(:sheet).last_edited_at
    assert_redirected_to [assigns(:project), assigns(:sheet)]
  end

  test 'should not make changes if reassign does not provide a new subject' do
    patch :reassign, params: { project_id: @project, id: @sheet, subject_id: subjects(:one) }
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_redirected_to [assigns(:project), assigns(:sheet)]
  end

  test 'should not reassign sheet to new subject for viewer' do
    login(users(:site_one_viewer))
    patch :reassign, params: { project_id: @project, id: @sheet, subject_id: subjects(:two) }
    assert_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to root_path
  end

  test 'should move sheet to subject event for editor' do
    patch :move_to_event, params: {
      project_id: @project, id: @sheet, subject_event_id: subject_events(:one)
    }, format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_equal subject_events(:one).id, assigns(:sheet).subject_event_id
    assert_equal users(:regular).id, assigns(:sheet).last_user_id
    assert_not_nil assigns(:sheet).last_edited_at
    assert_not_nil assigns(:sheet).subject
    assert_template 'move_to_event'
  end

  test 'should not make changes if move_to_event does not provide a new subject' do
    patch :move_to_event, params: {
      project_id: @project, id: @sheet
    }, format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_response :success
  end

  test 'should not move sheet to subject event for viewer' do
    login(users(:site_one_viewer))
    patch :move_to_event, params: {
      project_id: @project, id: @sheet, subject_event_id: subject_events(:one)
    }, format: 'js'
    assert_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_response :success
  end

  test 'should not move autolocked sheet to subject event for editor' do
    patch :move_to_event, params: {
      project_id: projects(:auto_lock), id: sheets(:auto_lock),
      subject_event_id: subject_events(:auto_lock_subject_one_event_one)
    }, format: 'js'
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_nil assigns(:sheet).subject_event_id
    assert_template 'move_to_event'
    assert_response :success
  end

  test 'should destroy sheet' do
    assert_difference('Sheet.current.count', -1) do
      delete :destroy, params: { id: @sheet, project_id: @project }
    end
    assert_not_nil assigns(:project)
    assert_not_nil assigns(:sheet)
    assert_redirected_to project_subject_path(@project, @sheet.subject)
  end

  test 'should destroy sheet with ajax' do
    assert_difference('Sheet.current.count', -1) do
      delete :destroy, params: { id: @sheet, project_id: @project }, format: 'js'
    end
    assert_template 'destroy'
    assert_response :success
  end

  test 'should not destroy sheet with invalid project' do
    assert_difference('Sheet.current.count', 0) do
      delete :destroy, params: { id: @sheet, project_id: -1 }
    end
    assert_nil assigns(:project)
    assert_nil assigns(:sheet)
    assert_redirected_to root_path
  end

  test 'should not destroy auto-locked sheet' do
    login(users(:regular))
    assert_difference('Sheet.current.count', 0) do
      delete :destroy, params: {
        project_id: projects(:auto_lock), id: sheets(:auto_lock)
      }
    end
    assert_equal 'This sheet is locked.', flash[:notice]
    assert_redirected_to [projects(:auto_lock), sheets(:auto_lock)]
  end
end
