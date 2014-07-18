require 'test_helper'

class ExportTest < ActiveSupport::TestCase

  test "generate an export with a sheet_scope" do
    exports(:two).generate_export!(projects(:one).sheets)
    assert_equal 'ready', exports(:two).status
  end

  test "generate an export with checkbox values split across columns" do
    sheets_with_checkboxes = projects(:one).sheets.where( id: sheets(:checkbox_example_one) )

    (location, export_file) = exports(:three).send('generate_csv_sheets', sheets_with_checkboxes, 'test-export.csv', true, '')
    rows = IO.readlines(export_file).collect{|l| l.strip}
    assert_equal "Sheet ID,Name,Description,Sheet Creation Date,Project,Site,Subject,Acrostic,Status,Creator,Schedule Name,Event Name,var_course_work,var_course_work__acct101,var_course_work__econ101,var_course_work__math123,var_course_work__phys500,var_course_work__biol327,var_year", rows[0]
    assert_equal "#{sheets(:checkbox_example_one).id},Checkbox and Radio for Export Test,,2014-07-18,Project One,Site One,Code01,,valid,FirstName LastName,,,\"econ101,math123\",,econ101,math123,,,1", rows[1]
  end

  test "generate an export with checkbox labeled values split across columns" do
    sheets_with_checkboxes = projects(:one).sheets.where( id: sheets(:checkbox_example_one) )

    (location, export_file) = exports(:three).send('generate_csv_sheets', sheets_with_checkboxes, 'test-export-labeled.csv', false, '')
    rows = IO.readlines(export_file).collect{|l| l.strip}
    assert_equal "Sheet ID,Name,Description,Sheet Creation Date,Project,Site,Subject,Acrostic,Status,Creator,Schedule Name,Event Name,var_course_work,var_course_work__acct101,var_course_work__econ101,var_course_work__math123,var_course_work__phys500,var_course_work__biol327,var_year", rows[0]
    assert_equal "#{sheets(:checkbox_example_one).id},Checkbox and Radio for Export Test,,2014-07-18,Project One,Site One,Code01,,valid,FirstName LastName,,,\"econ101: ECON 101,math123: MATH 123\",,econ101: ECON 101,math123: MATH 123,,,1: Freshman", rows[1]
  end

end
