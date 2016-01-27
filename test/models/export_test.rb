# frozen_string_literal: true

require 'test_helper'

class ExportTest < ActiveSupport::TestCase

  test 'generate an export with a sheet_scope' do
    exports(:two).generate_export!(projects(:one).sheets)
    assert_equal 'ready', exports(:two).status
  end

  test 'generate an export with checkbox values split across columns' do
    sheets_with_checkboxes = projects(:one).sheets.where( id: sheets(:checkbox_example_one) )

    (location, export_file) = exports(:three).send('generate_csv_sheets', sheets_with_checkboxes, 'test-export.csv', true, '')
    rows = IO.readlines(export_file).collect{|l| l.strip}
    assert_equal "Sheet ID,Name,Description,Sheet Creation Date,Project,Site,Subject,Acrostic,Status,Creator,Event Name,var_course_work,var_course_work__acct101,var_course_work__econ101,var_course_work__math123,var_course_work__phys500,var_course_work__biol327,var_year", rows[0]
    assert_equal "#{sheets(:checkbox_example_one).id},Checkbox and Radio for Export Test,,#{Date.today.strftime("%Y-%m-%d")},Project One,Site One,Code01,,valid,FirstName LastName,,\"econ101,math123\",,econ101,math123,,,1", rows[1]
  end

  test 'generate an export with checkbox labeled values split across columns' do
    sheets_with_checkboxes = projects(:one).sheets.where( id: sheets(:checkbox_example_one) )

    (location, export_file) = exports(:three).send('generate_csv_sheets', sheets_with_checkboxes, 'test-export-labeled.csv', false, '')
    rows = IO.readlines(export_file).collect{|l| l.strip}
    assert_equal "Sheet ID,Name,Description,Sheet Creation Date,Project,Site,Subject,Acrostic,Status,Creator,Event Name,var_course_work,var_course_work__acct101,var_course_work__econ101,var_course_work__math123,var_course_work__phys500,var_course_work__biol327,var_year", rows[0]
    assert_equal "#{sheets(:checkbox_example_one).id},Checkbox and Radio for Export Test,,#{Date.today.strftime('%Y-%m-%d')},Project One,Site One,Code01,,valid,FirstName LastName,,\"econ101: ECON 101,math123: MATH 123\",,econ101: ECON 101,math123: MATH 123,,,1: Freshman", rows[1]
  end

  test 'generate a grid export with rows for each grid row' do
    sheets_with_grids = projects(:one).sheets.where( id: sheets(:has_grid) )
    (location, export_file) = exports(:four).send('generate_csv_grids', sheets_with_grids, 'test-export-grids.csv', true, '')
    rows = IO.readlines(export_file).collect{|l| l.strip}
    assert_equal '"","","","","","","","","","","","",grid,grid,grid,grid,grid,grid,grid,grid', rows[0]
    assert_equal "Sheet ID,Name,Description,Sheet Creation Date,Project,Site,Subject,Acrostic,Status,Creator,Event Name,change_options,var_file,var_course_work,height,weight,var_bmi,var_age,var_time", rows[1]
    assert_equal "863765097,Includes a Grid Variable,Test for grid variable saving,#{Date.today.strftime("%Y-%m-%d")},Project One,Site One,Code01,,valid,FirstName LastName,,1,/grids/941303609/response_file/rails.png,econ101,1.5,70.0,31.11,25,43199", rows[2]
    assert_equal "863765097,Includes a Grid Variable,Test for grid variable saving,#{Date.today.strftime("%Y-%m-%d")},Project One,Site One,Code01,,valid,FirstName LastName,,2,\"\",\"\",2.6,80.0,11.83,36,43200", rows[3]
    assert_equal 4, rows.size
  end

end
