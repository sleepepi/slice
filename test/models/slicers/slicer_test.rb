# frozen_string_literal: true

require "test_helper"

# Test preparing values for storing in database.
class SlicerTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test "should prepare value for db for calculated variable" do
    slicer = Slicers.for(variables(:api_calculated))
    assert_equal(
      { value: "43", domain_option_id: nil },
      slicer.format_for_db_update("43")
    )
    # Should be "43.00"?
  end

  test "should prepare value for db for checkbox variable" do
    slicer = Slicers.for(variables(:api_checkbox))
    assert_equal(
      { value: nil, domain_option_id: domain_options(:api_checkbox_options_0).id },
      slicer.format_for_db_update("0")
    )
    assert_equal(
      { value: nil, domain_option_id: domain_options(:api_checkbox_options_1).id },
      slicer.format_for_db_update("1")
    )
    assert_equal(
      { value: nil, domain_option_id: domain_options(:api_checkbox_options_2).id },
      slicer.format_for_db_update("2")
    )
    assert_equal(
      { value: "3", domain_option_id: nil },
      slicer.format_for_db_update("3")
    )
  end

  test "should prepare value for db for date variable" do
    slicer = Slicers.for(variables(:api_date))
    assert_equal(
      { value: "1984-12-31" },
      slicer.format_for_db_update(year: "1984", month: "12", day: "31")
    )
  end

  test "should prepare value for db for dropdown variable" do
    slicer = Slicers.for(variables(:api_dropdown))
    assert_equal(
      { value: nil, domain_option_id: domain_options(:api_dropdown_options_9).id },
      slicer.format_for_db_update("-9")
    )
  end

  test "should prepare value for db for file variable" do
    slicer = Slicers.for(variables(:api_file))
    file = fixture_file_upload("../../test/support/projects/rails.png")
    assert_equal({}, slicer.format_for_db_update(""))
    assert_equal(
      { response_file: file },
      slicer.format_for_db_update(response_file: file)
    )
  end

  test "should prepare value for db for imperial height variable" do
    slicer = Slicers.for(variables(:api_imperial_height))
    assert_equal(
      { value: "74" },
      slicer.format_for_db_update(feet: "6", inches: "2")
    )
  end

  test "should prepare value for db for imperial weight variable" do
    slicer = Slicers.for(variables(:api_imperial_weight))
    assert_equal(
      { value: "2243" },
      slicer.format_for_db_update(pounds: "140", ounces: "3")
    )
  end

  test "should prepare value for db for integer variable" do
    slicer = Slicers.for(variables(:api_integer))
    assert_equal(
      { value: "42", domain_option_id: nil },
      slicer.format_for_db_update("42")
    )
  end

  test "should prepare value for db for integer variable with leading zero" do
    # TODO: Slicers don't currently handle value formatting. Instead they handle
    # hash generation for complex values and missing codes.
    skip
    slicer = Slicers.for(variables(:format_integer_view_count))
    assert_equal(
      { value: "20041", domain_option_id: nil },
      slicer.format_for_db_update("020041")
    )
    assert_equal(
      { value: "20041", domain_option_id: nil },
      slicer.format_for_db_update("00020041")
    )
    assert_equal(
      { value: "20041", domain_option_id: nil },
      slicer.format_for_db_update("+020041")
    )
    assert_equal(
      { value: "-20041", domain_option_id: nil },
      slicer.format_for_db_update("-020041")
    )
  end

  test "should prepare value for db for integer variable with domain" do
    slicer = Slicers.for(variables(:integer))
    assert_equal(
      { value: "42", domain_option_id: nil },
      slicer.format_for_db_update("42")
    )
    assert_equal(
      { value: nil, domain_option_id: domain_options(:integer_unknown_9).id },
      slicer.format_for_db_update("-9")
    )
  end

  test "should prepare value for db for numeric variable with domain" do
    slicer = Slicers.for(variables(:numeric))
    assert_equal(
      { value: "98.6", domain_option_id: nil },
      slicer.format_for_db_update("98.6")
    )
    assert_equal(
      { value: nil, domain_option_id: domain_options(:numeric_missing_1).id },
      slicer.format_for_db_update("-1")
    )
    assert_equal(
      { value: nil, domain_option_id: domain_options(:numeric_missing_1).id },
      slicer.format_for_db_update("-1.0")
    )
    assert_equal(
      { value: nil, domain_option_id: domain_options(:numeric_missing_2_0).id },
      slicer.format_for_db_update("-2")
    )
    assert_equal(
      { value: nil, domain_option_id: domain_options(:numeric_missing_2_0).id },
      slicer.format_for_db_update("-2.0")
    )
    assert_equal(
      { value: "", domain_option_id: nil },
      slicer.format_for_db_update("")
    )
    assert_equal(
      { value: {}, domain_option_id: nil },
      slicer.format_for_db_update({})
    )
    assert_equal(
      { value: nil, domain_option_id: nil },
      slicer.format_for_db_update(nil)
    )
  end

  test "should prepare value for db for numeric variable" do
    slicer = Slicers.for(variables(:api_numeric))
    assert_equal(
      { value: "98.6", domain_option_id: nil },
      slicer.format_for_db_update("98.6")
    )
  end

  test "should prepare value for db for radio variable" do
    slicer = Slicers.for(variables(:api_radio))
    assert_equal(
      { value: nil, domain_option_id: domain_options(:api_radio_options_1).id },
      slicer.format_for_db_update("1")
    )
  end

  test "should prepare value for db for string variable" do
    slicer = Slicers.for(variables(:api_string))
    assert_equal(
      { value: "My Pet Dog" },
      slicer.format_for_db_update("My Pet Dog")
    )
  end

  test "should prepare value for db for text variable" do
    slicer = Slicers.for(variables(:api_text))
    assert_equal(
      { value: "A Paragraph\n\nOne day I wrote an essay. It was great.\n\nThe End" },
      slicer.format_for_db_update("A Paragraph\n\nOne day I wrote an essay. It was great.\n\nThe End")
    )
  end

  test "should prepare value for db for time of day variable" do
    slicer = Slicers.for(variables(:api_time_of_day))
    assert_equal(
      { value: "54949" },
      slicer.format_for_db_update(hours: "3", minutes: "15", seconds: "49", period: "pm")
    )
  end

  test "should prepare value for db for time duration variable" do
    slicer = Slicers.for(variables(:api_time_duration))
    assert_equal(
      { value: "37231" },
      slicer.format_for_db_update(hours: "10", minutes: "20", seconds: "31")
    )
    assert_equal(
      { value: "3600" },
      slicer.format_for_db_update(hours: "1")
    )
    assert_equal(
      { value: "60" },
      slicer.format_for_db_update(minutes: "1")
    )
    assert_equal(
      { value: "1" },
      slicer.format_for_db_update(seconds: "1")
    )
  end

  test "should prepare value for db for signature variable" do
    slicer = Slicers.for(variables(:api_signature))
    signature_points = "[{\"lx\":0,\"ly\":0,\"mx\":5,\"my\":5},{\"lx\":100,\"ly\":100,\"mx\":5,\"my\":5}]"
    assert_equal(
      { value: signature_points },
      slicer.format_for_db_update(signature_points)
    )
  end
end
