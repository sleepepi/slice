# frozen_string_literal: true

require "test_helper"

# Tests to make sure projects are exported in an expected format
class ExportTest < ActiveSupport::TestCase
  setup do
    @temp_dir = Dir.mktmpdir
  end

  teardown do
    FileUtils.remove_entry @temp_dir
  end

  test "generate an export with a sheet_scope" do
    exports(:two).generate_export!
    assert_equal "ready", exports(:two).status
  end

  test "generate a labeled export for all variables" do
    sheets_with_all_variables = projects(:one).sheets.where(id: sheets(:all_variables))
    (_, export_file) = exports(:all_variables).send(
      :generate_csv_sheets, sheets_with_all_variables, @temp_dir, "test-export.csv", false, ""
    )
    rows = IO.readlines(export_file).collect(&:strip)
    assert_equal "Subject,Site,Event,Design,Sheet ID,Sheet Coverage Percent,Sheet Coverage Count,Sheet Coverage Total,Sheet Created,Initial Language Code,Missing,"\
                 "var_gender,var_course_work__acct101,var_course_work__econ101,"\
                 "var_course_work__math123,var_course_work__phys500,"\
                 "var_course_work__biol327,var_year,radio_no_domain,"\
                 "var_hobbies,var_life_goals,var_age,var_weight,var_date,"\
                 "var_file,time_of_day,var_bmi,var_bmi_no_format,"\
                 "var_autocomplete_animals,var_time_duration,imperial_height,"\
                 "imperial_weight,signature", rows[0]
    assert_equal "Code01,#{sites(:one).name},,"\
                 "#{designs(:all_variable_types).name},"\
                 "#{sheets(:all_variables).id},"\
                 "#{sheets(:all_variables).percent},"\
                 "#{sheets(:all_variables).response_count},"\
                 "#{sheets(:all_variables).total_response_count},"\
                 "#{sheets(:all_variables).created_at.strftime("%F %T")},"\
                 "en,0,m: Male,acct101: ACCT 101,econ101: ECON 101,,,,,,Weight Li"\
                 "fting and Salsa,\"This Text is across", rows[1]
    assert_equal "Multiple Lines\",-9: Unknown,,04/17/2013,,22:30:00,24.36 kg "\
                 "/ (m * m),,,57 hours 2 minutes 3 seconds,6 feet 2 inches,170"\
                 " pounds 5 ounces,", rows[2]
  end

  test "generate a raw export for all variables" do
    sheets_with_all_variables = projects(:one).sheets.where(id: sheets(:all_variables))
    (_, export_file) = exports(:all_variables).send(
      :generate_csv_sheets, sheets_with_all_variables, @temp_dir, "test-export.csv", true, ""
    )
    rows = IO.readlines(export_file).collect(&:strip)
    assert_equal "Subject,Site,Event,Design,Sheet ID,Sheet Coverage Percent,Sheet Coverage Count,Sheet Coverage Total,Sheet Created,Initial Language Code,Missing,"\
                 "var_gender,var_course_work__acct101,var_course_work__econ101,"\
                 "var_course_work__math123,var_course_work__phys500,"\
                 "var_course_work__biol327,var_year,radio_no_domain,"\
                 "var_hobbies,var_life_goals,var_age,var_weight,var_date,"\
                 "var_file,time_of_day,var_bmi,var_bmi_no_format,"\
                 "var_autocomplete_animals,var_time_duration,imperial_height,"\
                 "imperial_weight,signature", rows[0]
    assert_equal "Code01,#{sites(:one).number_or_id},,"\
                 "#{designs(:all_variable_types).id},"\
                 "#{sheets(:all_variables).id},"\
                 "#{sheets(:all_variables).percent},"\
                 "#{sheets(:all_variables).response_count},"\
                 "#{sheets(:all_variables).total_response_count},"\
                 "#{sheets(:all_variables).created_at.strftime("%F %T")},"\
                 "en,0,m,acct101,econ101,,,,,,Weight Lifting and Salsa,\"This Tex"\
                 "t is across", rows[1]
    assert_equal "Multiple Lines\",-9,,2013-04-17,,81000,24.36,,,205323,74,272"\
                 "5,", rows[2]
  end

  test "generate an export with checkbox values split across columns" do
    sheets_with_checkboxes = projects(:one).sheets.where(id: sheets(:checkbox_example_one))
    (_, export_file) = exports(:three).send(:generate_csv_sheets, sheets_with_checkboxes, @temp_dir, "test-export.csv", true, "")
    rows = IO.readlines(export_file).collect(&:strip)
    assert_equal "Subject,Site,Event,Design,Sheet ID,Sheet Coverage Percent,Sheet Coverage Count,Sheet Coverage Total,Sheet Created,Initial Language Code,Missing,"\
                 "var_course_work__acct101,var_course_work__econ101,"\
                 "var_course_work__math123,var_course_work__phys500,"\
                 "var_course_work__biol327,var_year", rows[0]
    assert_equal "Code01,#{sites(:one).number_or_id},,#{designs(:checkbox_and_radio).id},"\
                 "#{sheets(:checkbox_example_one).id},"\
                 "#{sheets(:checkbox_example_one).percent},"\
                 "#{sheets(:checkbox_example_one).response_count},"\
                 "#{sheets(:checkbox_example_one).total_response_count},"\
                 "#{sheets(:checkbox_example_one).created_at.strftime("%F %T")},"\
                 "en,0,,econ101,math123,,,1", rows[1]
  end

  test "generate an export with checkbox labeled values split across columns" do
    sheets_with_checkboxes = projects(:one).sheets.where(id: sheets(:checkbox_example_one))
    (_, export_file) = exports(:three).send(
      :generate_csv_sheets, sheets_with_checkboxes, @temp_dir, "test-export-labeled.csv", false, ""
    )
    rows = IO.readlines(export_file).collect(&:strip)
    assert_equal "Subject,Site,Event,Design,Sheet ID,Sheet Coverage Percent,Sheet Coverage Count,Sheet Coverage Total,Sheet Created,Initial Language Code,Missing,"\
                 "var_course_work__acct101,var_course_work__econ101,"\
                 "var_course_work__math123,var_course_work__phys500,"\
                 "var_course_work__biol327,var_year", rows[0]
    assert_equal "Code01,Site One,,Checkbox and Radio for Export Test,#{sheets(:checkbox_example_one).id},"\
                 "#{sheets(:checkbox_example_one).percent},"\
                 "#{sheets(:checkbox_example_one).response_count},"\
                 "#{sheets(:checkbox_example_one).total_response_count},"\
                 "#{sheets(:checkbox_example_one).created_at.strftime("%F %T")},"\
                 "en,0,,econ101: ECON 101,math123: MATH 123,,,1: Freshman", rows[1]
  end

  test "generate a grid export with rows for each grid row" do
    sheets_with_grids = projects(:one).sheets.where(id: sheets(:has_grid))
    (_, export_file) = exports(:four).send(:generate_csv_grids, sheets_with_grids, @temp_dir, "test-export-grids.csv", true, "")
    rows = IO.readlines(export_file).collect(&:strip)
    assert_equal '"","","","","",grid,grid,grid,grid,grid,grid,grid,grid,grid,grid,grid', rows[0]
    assert_equal "Subject,Site,Event,Design,Sheet ID,change_options,"\
                 "var_course_work__acct101,var_course_work__econ101,"\
                 "var_course_work__math123,var_course_work__phys500,var_course_work__biol327,"\
                 "height,weight,var_bmi,var_age,time_of_day", rows[1]
    assert_equal "Code01,#{sites(:one).number_or_id},,#{designs(:has_grid).id},863765097,1,"\
                 ",econ101,,,,1.5,70.0,31.11,25,43199", rows[2]
    assert_equal "Code01,#{sites(:one).number_or_id},,#{designs(:has_grid).id},863765097,2,"\
                 ",,,,,2.6,80.0,11.83,36,43200", rows[3]
    assert_equal 4, rows.size
  end
end
