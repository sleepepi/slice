# frozen_string_literal: true

require 'test_helper'

# Tests to make sure projects are exported in an expected format
class ExportTest < ActiveSupport::TestCase
  test 'generate an export with a sheet_scope' do
    exports(:two).generate_export!
    assert_equal 'ready', exports(:two).status
  end

  test 'generate an export with checkbox values split across columns' do
    sheets_with_checkboxes = projects(:one).sheets.where(id: sheets(:checkbox_example_one))
    (_, export_file) = exports(:three).send(:generate_csv_sheets, sheets_with_checkboxes, 'test-export.csv', true, '')
    rows = IO.readlines(export_file).collect(&:strip)
    assert_equal 'Subject,Site,Event Name,Design Name,Sheet ID,Sheet Created,Missing,'\
                 'var_course_work__acct101,var_course_work__econ101,'\
                 'var_course_work__math123,var_course_work__phys500,'\
                 'var_course_work__biol327,var_year', rows[0]
    assert_equal "Code01,Site One,,Checkbox and Radio for Export Test,#{sheets(:checkbox_example_one).id},"\
                 "#{sheets(:checkbox_example_one).created_at.strftime('%F %T')},0,,econ101,math123,,,1", rows[1]
  end

  test 'generate an export with checkbox labeled values split across columns' do
    sheets_with_checkboxes = projects(:one).sheets.where(id: sheets(:checkbox_example_one))
    (_, export_file) = exports(:three).send(
      :generate_csv_sheets, sheets_with_checkboxes, 'test-export-labeled.csv', false, ''
    )
    rows = IO.readlines(export_file).collect(&:strip)
    assert_equal 'Subject,Site,Event Name,Design Name,Sheet ID,Sheet Created,Missing,'\
                 'var_course_work__acct101,var_course_work__econ101,'\
                 'var_course_work__math123,var_course_work__phys500,'\
                 'var_course_work__biol327,var_year', rows[0]
    assert_equal "Code01,Site One,,Checkbox and Radio for Export Test,#{sheets(:checkbox_example_one).id},"\
                 "#{sheets(:checkbox_example_one).created_at.strftime('%F %T')},"\
                 '0,,econ101: ECON 101,math123: MATH 123,,,1: Freshman', rows[1]
  end

  test 'generate a grid export with rows for each grid row' do
    sheets_with_grids = projects(:one).sheets.where(id: sheets(:has_grid))
    (_, export_file) = exports(:four).send(:generate_csv_grids, sheets_with_grids, 'test-export-grids.csv', true, '')
    rows = IO.readlines(export_file).collect(&:strip)
    assert_equal '"","","","","",grid,grid,grid,grid,grid,grid,grid,grid,grid,grid,grid,grid', rows[0]
    assert_equal 'Subject,Site,Event Name,Design Name,Sheet ID,change_options,'\
                 'var_file,var_course_work__acct101,var_course_work__econ101,'\
                 'var_course_work__math123,var_course_work__phys500,var_course_work__biol327,'\
                 'height,weight,var_bmi,var_age,time_of_day', rows[1]
    assert_equal 'Code01,Site One,,Includes a Grid Variable,863765097,1,rails.png,'\
                 ',econ101,,,,1.5,70.0,31.11,25,43199', rows[2]
    assert_equal 'Code01,Site One,,Includes a Grid Variable,863765097,2,,'\
                 ',,,,,2.6,80.0,11.83,36,43200', rows[3]
    assert_equal 4, rows.size
  end
end
