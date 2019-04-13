# frozen_string_literal: true

require "test_helper"

# Test to make sure that project and site editors can modify sheets.
class SheetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project_editor = users(:regular)
    @site_editor = users(:site_one_editor)
    @site_viewer = users(:site_one_viewer)
    @sheet = sheets(:one)
    @project = projects(:one)
  end

  test "should get index" do
    login(@project_editor)
    get project_sheets_url(@project)
    assert_response :success
  end

  test "should search for sheets by date" do
    login(@project_editor)
    get project_sheets_url(@project), params: { search: "created:2016-11-04" }
    assert_response :success
  end

  test "should search for sheets with invalid date" do
    login(@project_editor)
    get project_sheets_url(@project), params: { search: "created:2016-02-30" }
    assert_response :success
  end

  test "should search for sheets by less than date" do
    login(@project_editor)
    get project_sheets_url(@project), params: { search: "created:<2016-11-04" }
    assert_response :success
  end

  test "should search for sheets by greater than date" do
    login(@project_editor)
    get project_sheets_url(@project), params: { search: "created:>2016-11-04" }
    assert_response :success
  end

  test "should search for sheets by less than or equal to date" do
    login(@project_editor)
    get project_sheets_url(@project), params: { search: "created:<=2016-11-04" }
    assert_response :success
  end

  test "should search for sheets by greater than or equal to date" do
    login(@project_editor)
    get project_sheets_url(@project), params: { search: "created:>=2016-11-04" }
    assert_response :success
  end

  test "should search for sheets by variable" do
    login(@project_editor)
    get project_sheets_url(@project), params: { search: "var_1:1" }
    assert_response :success
  end

  test "should search for sheets by non-existent variable" do
    login(@project_editor)
    get project_sheets_url(@project), params: { search: "var_does_not_exist:present" }
    assert_response :success
  end

  test "should search for sheets with comments" do
    login(@project_editor)
    get project_sheets_url(@project), params: { search: "has:comments" }
    assert_response :success
  end

  test "should search for sheets with adverse events" do
    login(@project_editor)
    get project_sheets_url(@project), params: { search: "has:adverse-events" }
    assert_response :success
  end

  test "should search for sheets with files" do
    login(@project_editor)
    get project_sheets_url(@project), params: { search: "has:files" }
    assert_response :success
  end

  test "should search for sheets that fail checks" do
    login(@project_editor)
    get project_sheets_url(@project), params: { search: "checks:present" }
    assert_response :success
  end

  test "should search for sheets that are on an event" do
    login(@project_editor)
    get project_sheets_url(@project), params: { search: "events:present" }
    assert_response :success
  end

  test "should search for sheets that are not on an event" do
    login(@project_editor)
    get project_sheets_url(@project), params: { search: "events:missing" }
    assert_response :success
  end

  test "should search for sheets that have coverage computed" do
    login(@project_editor)
    get project_sheets_url(@project), params: { search: "coverage:present" }
    assert_response :success
  end

  test "should search for sheets that do not have coverage computed" do
    login(@project_editor)
    get project_sheets_url(@project), params: { search: "coverage:missing" }
    assert_response :success
  end

  test "should search for sheets that do have coverage greater than 80 percent" do
    login(@project_editor)
    get project_sheets_url(@project), params: { search: "coverage:>80" }
    assert_response :success
  end

  test "should search for sheets that do have coverage that is not an integer" do
    login(@project_editor)
    get project_sheets_url(@project), params: { search: "coverage:a" }
    assert_response :success
  end

  test "should search for sheets for randomized subjects" do
    login(@project_editor)
    get project_sheets_url(@project), params: { search: "is:randomized" }
    assert_response :success
  end

  test "should search for sheets for un-randomized subjects" do
    login(@project_editor)
    get project_sheets_url(@project), params: { search: "not:randomized" }
    assert_response :success
  end

  test "should get index with invalid project" do
    login(@project_editor)
    get project_sheets_url(-1)
    assert_redirected_to root_url
  end

  test "should get paginated index" do
    login(@project_editor)
    get project_sheets_url(@project), params: { page: 2 }
    assert_response :success
  end

  test "should get index order by site" do
    login(@project_editor)
    get project_sheets_url(@project), params: { order: "site" }
    assert_response :success
  end

  test "should get index order by site descending" do
    login(@project_editor)
    get project_sheets_url(@project), params: { order: "site desc" }
    assert_response :success
  end

  test "should get index by design" do
    login(@project_editor)
    get project_sheets_url(@project), params: { order: "design" }
    assert_response :success
  end

  test "should get index by design desc" do
    login(@project_editor)
    get project_sheets_url(@project), params: { order: "design desc" }
    assert_response :success
  end

  test "should get index by subject" do
    login(@project_editor)
    get project_sheets_url(@project), params: { order: "subject" }
    assert_response :success
  end

  test "should get index by subject desc" do
    login(@project_editor)
    get project_sheets_url(@project), params: { order: "subject desc" }
    assert_response :success
  end

  test "should get index by percent" do
    login(@project_editor)
    get project_sheets_url(@project), params: { order: "percent" }
    assert_response :success
  end

  test "should get index by percent desc" do
    login(@project_editor)
    get project_sheets_url(@project), params: { order: "percent desc" }
    assert_response :success
  end

  test "should get index by created by" do
    login(@project_editor)
    get project_sheets_url(@project), params: { order: "created_by" }
    assert_response :success
  end

  test "should get index by created by desc" do
    login(@project_editor)
    get project_sheets_url(@project), params: { order: "created_by desc" }
    assert_response :success
  end

  test "should get index by created" do
    login(@project_editor)
    get project_sheets_url(@project), params: { order: "created" }
    assert_response :success
  end

  test "should get index by created desc" do
    login(@project_editor)
    get project_sheets_url(@project), params: { order: "created desc" }
    assert_response :success
  end

  test "should get index by edited" do
    login(@project_editor)
    get project_sheets_url(@project), params: { order: "edited" }
    assert_response :success
  end

  test "should get index by edited desc" do
    login(@project_editor)
    get project_sheets_url(@project), params: { order: "edited desc" }
    assert_response :success
  end

  test "should get attached file" do
    login(@project_editor)
    assert_not_equal 0, sheet_variables(:file_attachment).response_file.size
    get file_project_sheet_url(@project, sheets(:file_attached)), params: {
      sheet_variable_id: sheet_variables(:file_attachment).id,
      variable_id: variables(:file).id,
      position: nil
    }
    assert_equal File.binread(assigns(:object).response_file.path), response.body
  end

  test "should get attached file in grid" do
    login(@project_editor)
    assert_not_equal 0, grids(:has_grid_row_one_attached_file).response_file.size
    get file_project_sheet_url(@project, sheets(:has_grid_with_file)), params: {
      sheet_variable_id: sheet_variables(:has_grid_with_file).id,
      variable_id: variables(:file).id,
      position: 0
    }
    assert_equal File.binread(assigns(:object).response_file.path), response.body
  end

  test "should not get non-existent file in grid" do
    login(@project_editor)
    assert_equal 0, grids(:has_grid_row_two_no_attached_file).response_file.size
    get file_project_sheet_url(@project, sheets(:has_grid_with_file)), params: {
      sheet_variable_id: sheet_variables(:has_grid_with_file).id,
      variable_id: variables(:file).id,
      position: 1
    }
    assert_equal 0, assigns(:object).response_file.size
    assert_response :success
  end

  test "should not get attached file for viewer on different site" do
    login(@site_viewer)
    assert_not_equal 0, sheet_variables(:file_attachment).response_file.size
    get file_project_sheet_url(@project, sheets(:file_attached)), params: {
      sheet_variable_id: sheet_variables(:file_attachment).id,
      variable_id: variables(:file).id,
      position: nil
    }
    assert_redirected_to project_sheets_url(@project)
  end

  test "should get new and redirect" do
    login(@project_editor)
    get new_project_sheet_url(@project)
    assert_redirected_to @project
  end

  test "should create sheet" do
    login(@project_editor)
    assert_difference("SheetTransaction.count") do
      assert_difference("Sheet.count") do
        post project_sheets_url(@project), params: {
          subject_id: @sheet.subject.id,
          sheet: { design_id: designs(:all_variable_types).id },
          variables: {
            variables(:dropdown).id.to_s => "m",
            variables(:checkbox).id.to_s => %w(acct101 econ101),
            variables(:radio).id.to_s => "2",
            variables(:string).id.to_s => "This is a string",
            variables(:text).id.to_s => "Lorem ipsum dolor sit amet, consectetu\
r adipisicing elit, sed do eiusmod tempor incididunt ut labore et d\olore magna\
 aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nis\
i ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in\
 voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint oc\
caecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim i\
d est laborum.",
            variables(:integer).id.to_s => 30,
            variables(:numeric).id.to_s => 180.5,
            variables(:date).id.to_s => {
              month: "05", day: "28", year: "2012"
            },
            variables(:file).id.to_s => { response_file: "" },
            variables(:time_of_day).id.to_s => {
              hours: "14", minutes: "30", seconds: "00"
            },
            variables(:calculated).id.to_s => "1234"
          }
        }
      end
    end
    assert_equal 11, assigns(:sheet).variables.size
    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test "should create sheet with large integer" do
    login(@project_editor)
    assert_difference("SheetTransaction.count") do
      assert_difference("Sheet.count") do
        post project_sheets_url(@project), params: {
          subject_id: @sheet.subject.id,
          sheet: { design_id: designs(:has_no_validations).id },
          variables: {
            variables(:integer_no_range).id.to_s => 127_858_751_212_122_128_384
          }
        }
      end
    end
    assigns(:sheet).sheet_variables.reload
    assert_equal 127_858_751_212_122_128_384, assigns(:sheet).sheet_variables.first.get_response(:raw)
    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test "should create sheet and save date to correct database format" do
    login(@project_editor)
    assert_difference("SheetTransaction.count") do
      assert_difference("Sheet.count") do
        post project_sheets_url(@project), params: {
          subject_id: @sheet.subject.id,
          sheet: { design_id: designs(:has_no_validations).id },
          variables: {
            variables(:date_no_range).id.to_s => {
              month: "5", day: "2", year: "1992"
            }
          }
        }
      end
    end
    assigns(:sheet).sheet_variables.reload
    assert_equal "1992-05-02", assigns(:sheet).sheet_variables.first.get_response(:raw)
    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test "should create sheet and save time of day to correct database format" do
    login(@project_editor)
    assert_difference("SheetTransaction.count") do
      assert_difference("Sheet.count") do
        post project_sheets_url(@project), params: {
          subject_id: @sheet.subject.id,
          sheet: { design_id: designs(:has_no_validations).id },
          variables: {
            variables(:time_of_day_no_range).id.to_s => {
              hours: "13", minutes: "2", seconds: ""
            }
          }
        }
      end
    end
    assigns(:sheet).sheet_variables.reload
    assert_equal "46920", assigns(:sheet).sheet_variables.first.get_response(:raw)
    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end


  test "should create sheet with leading zeros" do
    login(users(:format_editor))
    assert_difference("SheetTransaction.count") do
      assert_difference("Sheet.count") do
        post project_sheets_url(projects(:format)), params: {
          subject_id: subjects(:format_zeros).id,
          sheet: { design_id: designs(:format_leading_zeros).id },
          variables: {
            variables(:format_string_zip_code).id.to_s => "020041",
            variables(:format_integer_view_count).id.to_s => "020041",
            variables(:format_numeric_average_snowfall).id.to_s => "020041"
          }
        }
      end
    end
    assigns(:sheet).sheet_variables.reload
    assert_equal "020041", assigns(:sheet).sheet_variables.find_by(variable: variables(:format_string_zip_code)).get_response(:raw)
    assert_equal 20_041, assigns(:sheet).sheet_variables.find_by(variable: variables(:format_integer_view_count)).get_response(:raw)
    assert_equal 20_041.0, assigns(:sheet).sheet_variables.find_by(variable: variables(:format_numeric_average_snowfall)).get_response(:raw)
    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  # TODO, rewrite these for subject_events
  # test "should create sheet with subject schedule and event" do
  #   assert_difference("Sheet.count") do
  #     post :create, project_id: @project, sheet: { design_id: designs(:all_variable_types).id, subject_schedule_id: subject_schedules(:one).id, event_id: events(:one).id },
  #                   subject_code: subjects(:two).subject_code,
  #                   site_id: subjects(:two).site_id,
  #                   variables: { }
  #   end
  #   assert_redirected_to project_subject_url(assigns(:sheet).subject.project, assigns(:sheet).subject)
  # end

  # TODO, rewrite these for subject_events
  # test "should create sheet with and remove subject schedule and event if the subject is changed" do
  #   assert_difference("Sheet.count") do
  #     post :create, project_id: @project, sheet: { design_id: designs(:all_variable_types).id, subject_schedule_id: subject_schedules(:one).id, event_id: events(:one).id },
  #                   subject_code: subjects(:one).subject_code,
  #                   site_id: subjects(:one).site_id,
  #                   variables: { }
  #   end
  #   assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  # end

  test "should create sheet with grid" do
    login(@project_editor)
    post project_sheets_url(@project), params: {
      subject_id: sheets(:has_grid).subject.id,
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
    assert_equal 1, assigns(:sheet).variables.size
    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test "should not create sheet on invalid project" do
    login(@project_editor)
    assert_difference("Sheet.count", 0) do
      post project_sheets_url(projects(:four)), params: {
        subject_id: subjects(:one).id,
        sheet: { design_id: @sheet.design_id }
      }
    end
    assert_redirected_to root_url
  end

  test "should not create sheet without design" do
    login(@project_editor)
    assert_difference("Sheet.count", 0) do
      post project_sheets_url(@project), params: {
        subject_id: subjects(:one).id,
        sheet: { design_id: "" }
      }
    end
    assert_template "new"
    assert_response :success
  end

  test "should not create sheet for site viewer" do
    login(@site_viewer)
    assert_difference("Sheet.count", 0) do
      post project_sheets_url(@project), params: {
        subject_id: subjects(:one).id,
        sheet: { design_id: @sheet.design_id }
      }
    end
    assert_redirected_to root_url
  end

  test "should create sheet for site editor" do
    login(@site_editor)
    assert_difference("Sheet.count") do
      post project_sheets_url(@project), params: {
        subject_id: subjects(:one).id,
        sheet: { design_id: @sheet.design_id }
      }
    end
    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test "should show sheet" do
    login(@project_editor)
    get project_sheet_url(@project, @sheet)
    assert_response :success
  end

  test "should show sheet to site viewer" do
    login(@site_viewer)
    get project_sheet_url(@project, @sheet)
    assert_response :success
  end

  test "should show sheet with all variables" do
    login(@project_editor)
    get project_sheet_url(sheets(:all_variables).project, sheets(:all_variables))
    assert_response :success
  end

  test "should show sheet with grid responses" do
    login(@project_editor)
    get project_sheet_url(@project, sheets(:has_grid))
    assert_response :success
  end

  test "should show sheet with attached file" do
    login(@project_editor)
    get project_sheet_url(@project, sheets(:file_attached))
    assert_response :success
  end

  test "should show sheet transactions" do
    login(@project_editor)
    get transactions_project_sheet_url(@project, @sheet)
    assert_response :success
  end

  test "should not show invalid sheet" do
    login(@project_editor)
    get project_sheet_url(@project, -1)
    assert_redirected_to project_sheets_url(@project)
  end

  test "should not show sheet with invalid project" do
    login(@project_editor)
    get project_sheet_url(-1, @sheet)
    assert_redirected_to root_url
  end

  test "should get sheet coverage" do
    login(@project_editor)
    post coverage_project_sheet_url(@project, @sheet, format: "js")
    assert_template "coverage"
    assert_response :success
  end

  test "should not show transactions for invalid sheet" do
    login(@project_editor)
    get transactions_project_sheet_url(@project, -1)
    assert_redirected_to project_sheets_url(@project)
  end

  test "should not show transactions for invalid project" do
    login(@project_editor)
    get transactions_project_sheet_url(-1, @sheet)
    assert_redirected_to root_url
  end

  test "should not show sheet for user from different site" do
    login(@site_viewer)
    get project_sheet_url(@project, sheets(:three))
    assert_redirected_to project_sheets_url(@project)
  end

  test "should print sheet" do
    skip if ENV["TRAVIS"] # Skip this test on Travis since Travis can't generate PDFs
    login(@project_editor)
    get project_sheet_url(@project, @sheet, format: "pdf")
    assert_response :success
  end

  test "should print sheet on project that hides values" do
    skip if ENV["TRAVIS"] # Skip this test on Travis since Travis can't generate PDFs
    login(@project_editor)
    get project_sheet_url(projects(:two), sheets(:two_a), format: "pdf")
    assert_response :success
  end

  test "should not print invalid sheet" do
    skip if ENV["TRAVIS"] # Skip this test on Travis since Travis can't generate PDFs
    login(@project_editor)
    get project_sheet_url(@project, -1, format: "pdf")
    assert_redirected_to project_sheets_url(@project)
  end

  test "should show empty response if PDF fails to render" do
    skip if ENV["TRAVIS"] # Skip this test on Travis since Travis can't generate PDFs
    login(@project_editor)
    begin
      original_latex = ENV["latex_location"]
      ENV["latex_location"] = "echo #{original_latex}"
      get project_sheet_url(@project, sheets(:three), format: "pdf")
      assert_response :ok
    ensure
      ENV["latex_location"] = original_latex
    end
  end

  test "should get edit" do
    login(@project_editor)
    get edit_project_sheet_url(@project, @sheet)
    assert_response :success
  end

  test "should get edit for site editor" do
    login(@site_editor)
    get edit_project_sheet_url(@project, @sheet)
    assert_response :success
  end

  test "should not get edit for site viewer" do
    login(@site_viewer)
    get edit_project_sheet_url(@project, @sheet)
    assert_redirected_to root_url
  end

  test "should not get edit for auto-locked sheet" do
    login(@project_editor)
    get edit_project_sheet_url(projects(:auto_lock), sheets(:auto_lock))
    assert_redirected_to [projects(:auto_lock), sheets(:auto_lock)]
  end

  test "should set sheet as not missing" do
    login(@project_editor)
    post set_as_not_missing_project_sheet_url(projects(:auto_lock), sheets(:missing), format: "js")
    assert_equal true, assigns(:sheet).deleted?
    assert_template "subject_event"
    assert_response :success
  end

  test "should update sheet" do
    login(@project_editor)
    assert_difference("SheetTransaction.count") do
      patch project_sheet_url(@project, @sheet), params: {
        sheet: { design_id: designs(:all_variable_types).id },
        variables: {
          variables(:dropdown).id.to_s => "f",
          variables(:checkbox).id.to_s => nil,
          variables(:radio).id.to_s => "1",
          variables(:string).id.to_s => "This is an updated string",
          variables(:text).id.to_s => "Lorem ipsum dolor sit amet",
          variables(:integer).id.to_s => 31,
          variables(:numeric).id.to_s => 190.5,
          variables(:date).id.to_s => { month: "05", day: "29", year: "2012" },
          variables(:file).id.to_s => { response_file: fixture_file_upload(file_fixture("rails.png")) }
        }
      }
    end
    assert_not_nil assigns(:sheet)
    assert_equal 9, assigns(:sheet).variables.size
    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test "should update sheet with grid" do
    login(@project_editor)
    patch project_sheet_url(@project, sheets(:has_grid)), params: {
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
    sheets(:has_grid).reload
    assert_equal 1, sheets(:has_grid).variables.size
    assert_redirected_to [@project, sheets(:has_grid)]
  end

  test "should update sheet with grid and remove top grid row" do
    login(@project_editor)
    patch project_sheet_url(@project, sheets(:has_grid)), params: {
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
            variables(:file).id.to_s => { response_file: fixture_file_upload(file_fixture("rails.png")) },
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
    sheets(:has_grid).reload
    assert_equal 1, sheets(:has_grid).variables.size
    assert_redirected_to [@project, sheets(:has_grid)]
  end

  test "should update sheet with grid and remove all grid rows" do
    login(@project_editor)
    patch project_sheet_url(sheets(:has_grid).project, sheets(:has_grid)), params: {
      sheet: { design_id: designs(:has_grid).id },
      variables: {
        variables(:grid).id.to_s => {
          "-1" => { "-1" => "" }
        }
      }
    }
    assert_equal 1, assigns(:sheet).variables.size
    assert_equal 0, Grid.where(sheet_variable: assigns(:sheet).sheet_variables).count
    assert_redirected_to [assigns(:sheet).project, assigns(:sheet)]
  end

  test "should not update sheet with blank design" do
    login(@project_editor)
    patch project_sheet_url(@project, @sheet), params: {
      sheet: { design_id: "" }, variables: {}
    }
    assert_template "edit"
    assert_response :success
  end

  test "should not update invalid sheet" do
    login(@project_editor)
    patch project_sheet_url(@project, -1), params: {
      sheet: { design_id: designs(:all_variable_types).id }, variables: {}
    }
    assert_redirected_to project_sheets_url(@project)
  end

  test "should not update sheet with invalid project" do
    login(@project_editor)
    patch project_sheet_url(-1, @sheet), params: {
      sheet: { design_id: designs(:all_variable_types).id }, variables: {}
    }
    assert_redirected_to root_url
  end

  test "should not update auto-locked sheet" do
    login(@project_editor)
    assert_difference("SheetVariable.count", 0) do
      patch project_sheet_url(projects(:auto_lock), sheets(:auto_lock)), params: {
        variables: {
          variables(:string_on_auto_lock).id.to_s => "Updated string"
        }
      }
    end
    assert_equal "This sheet is locked.", flash[:notice]
    assert_redirected_to [projects(:auto_lock), sheets(:auto_lock)]
  end

  test "should unlock sheet as project editor" do
    login(@project_editor)
    assert_equal true, sheets(:auto_lock).auto_locked?
    post unlock_project_sheet_url(projects(:auto_lock), sheets(:auto_lock))
    sheets(:auto_lock).reload
    assert_equal false, sheets(:auto_lock).auto_locked?
    assert_redirected_to [projects(:auto_lock), sheets(:auto_lock)]
  end

  test "should not unlock sheet as site editor" do
    login(users(:auto_lock_site_one_editor))
    assert_equal true, sheets(:auto_lock).auto_locked?
    post unlock_project_sheet_url(projects(:auto_lock), sheets(:auto_lock))
    sheets(:auto_lock).reload
    assert_equal true, sheets(:auto_lock).auto_locked?
    assert_redirected_to root_url
  end

  test "should remove shareable link as editor" do
    login(users(:admin))
    assert_difference("Sheet.where(authentication_token: nil).count") do
      post remove_shareable_link_project_sheet_url(projects(:three), sheets(:external))
    end
    assert_redirected_to [projects(:three), sheets(:external)]
  end

  test "should get change event sheet for editor" do
    login(@project_editor)
    get change_event_project_sheet_url(@project, @sheet)
    assert_response :success
  end

  test "should change event sheet to new subject for editor" do
    login(@project_editor)
    post submit_change_event_project_sheet_url(@project, @sheet), params: {
      sheet: {
        subject_event_id: ""
      }
    }
    @sheet.reload
    assert_nil @sheet.subject_event_id
    assert_redirected_to [@project, @sheet]
  end

  test "should get reassign sheet for editor" do
    login(@project_editor)
    get reassign_project_sheet_url(@project, @sheet)
    assert_response :success
  end

  test "should not get reassign sheet for viewer" do
    login(@site_viewer)
    get reassign_project_sheet_url(@project, @sheet)
    assert_redirected_to root_url
  end

  test "should not get reassign sheet for auto-locked sheet" do
    login(users(:auto_lock_site_one_editor))
    get reassign_project_sheet_url(projects(:auto_lock), sheets(:auto_lock))
    assert_redirected_to [projects(:auto_lock), sheets(:auto_lock)]
  end

  test "should reassign sheet to new subject for editor" do
    login(@project_editor)
    patch reassign_project_sheet_url(@project, @sheet), params: {
      subject_id: subjects(:two).id
    }
    assert_equal subjects(:two).id, assigns(:sheet).subject_id
    assert_nil assigns(:sheet).subject_event_id
    assert_equal users(:regular).id, assigns(:sheet).last_user_id
    assert_not_nil assigns(:sheet).last_edited_at
    assert_redirected_to [@project, @sheet]
  end

  test "should undo reassign for subject for editor" do
    login(@project_editor)
    patch reassign_project_sheet_url(@project, @sheet), params: {
      subject_id: subjects(:two).id, undo: "1"
    }
    assert_equal subjects(:two).id, assigns(:sheet).subject_id
    assert_nil assigns(:sheet).subject_event_id
    assert_equal users(:regular).id, assigns(:sheet).last_user_id
    assert_not_nil assigns(:sheet).last_edited_at
    assert_redirected_to [assigns(:project), assigns(:sheet)]
  end

  test "should not make changes if reassign does not provide a new subject" do
    login(@project_editor)
    patch reassign_project_sheet_url(@project, @sheet), params: {
      subject_id: subjects(:one).id
    }
    assert_redirected_to [assigns(:project), assigns(:sheet)]
  end

  test "should not reassign sheet to new subject for viewer" do
    login(@site_viewer)
    patch reassign_project_sheet_url(@project, @sheet), params: {
      subject_id: subjects(:two).id
    }
    assert_redirected_to root_url
  end

  test "should move sheet to subject event for editor" do
    login(@project_editor)
    patch move_to_event_project_sheet_url(@project, @sheet), params: {
      subject_event_id: subject_events(:one).id, format: "js"
    }
    assert_equal subject_events(:one).id, assigns(:sheet).subject_event_id
    assert_equal users(:regular).id, assigns(:sheet).last_user_id
    assert_not_nil assigns(:sheet).last_edited_at
    assert_not_nil assigns(:sheet).subject
    assert_template "move_to_event"
  end

  test "should not make changes if move_to_event does not provide a new subject event" do
    login(@project_editor)
    patch move_to_event_project_sheet_url(@project, @sheet), params: { format: "js" }
    assert_response :success
  end

  test "should not move sheet to subject event for viewer" do
    login(@site_viewer)
    patch move_to_event_project_sheet_url(@project, @sheet), params: {
      subject_event_id: subject_events(:one).id, format: "js"
    }
    assert_response :success
  end

  test "should not move autolocked sheet to subject event for editor" do
    login(@project_editor)
    patch move_to_event_project_sheet_url(projects(:auto_lock), sheets(:auto_lock)), params: {
      subject_event_id: subject_events(:auto_lock_subject_one_event_one).id, format: "js"
    }
    assert_nil assigns(:sheet).subject_event_id
    assert_template "move_to_event"
    assert_response :success
  end

  test "should destroy sheet" do
    login(@project_editor)
    assert_difference("Sheet.current.count", -1) do
      delete project_sheet_url(@project, @sheet)
    end
    assert_redirected_to project_subject_url(@project, @sheet.subject)
  end

  test "should destroy sheet with ajax" do
    login(@project_editor)
    assert_difference("Sheet.current.count", -1) do
      delete project_sheet_url(@project, @sheet, format: "js")
    end
    assert_template "destroy"
    assert_response :success
  end

  test "should not destroy sheet with invalid project" do
    login(@project_editor)
    assert_difference("Sheet.current.count", 0) do
      delete project_sheet_url(-1, @sheet)
    end
    assert_redirected_to root_url
  end

  test "should not destroy auto-locked sheet" do
    login(users(:regular)) # This is project_editor on @project, but not on auto_lock
    assert_difference("Sheet.current.count", 0) do
      delete project_sheet_url(projects(:auto_lock), sheets(:auto_lock))
    end
    assert_equal "This sheet is locked.", flash[:notice]
    assert_redirected_to [projects(:auto_lock), sheets(:auto_lock)]
  end
end
