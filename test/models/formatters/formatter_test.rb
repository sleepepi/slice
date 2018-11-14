# frozen_string_literal: true

require "test_helper"

# Test formatting values.
class FormatterTest < ActiveSupport::TestCase
  test "should format values for integer variable with leading zero" do
    # Ruby interprets integers with leading zeros as octals. Slice needs to
    # strip the leading zeros in these cases to correctly store the integers.
    formatter = Formatters.for(variables(:format_integer_view_count))
    assert_equal Formatters::IntegerFormatter, formatter.class
    assert_equal Integer, formatter.raw_response("020041").class

    assert_equal 20041, formatter.raw_response(20041)
    assert_equal 0, formatter.raw_response("0")
    assert_equal 20041, formatter.raw_response("020041")
    assert_equal 20041, formatter.raw_response("00020041")
    assert_equal 20041, formatter.raw_response("+020041")
    assert_equal -20041, formatter.raw_response("-020041")
  end

  test "should format values for numeric variable with leading zero" do
    formatter = Formatters.for(variables(:format_numeric_average_snowfall))
    assert_equal Formatters::NumericFormatter, formatter.class
    assert_equal Float, formatter.raw_response("020041").class
    assert_equal 20041.0, formatter.raw_response(20041)
    assert_equal 0.0, formatter.raw_response("0")
    assert_equal 20041.0, formatter.raw_response("020041")
    assert_equal 20041.0, formatter.raw_response("00020041")
    assert_equal 20041.0, formatter.raw_response("+020041")
    assert_equal -20041.0, formatter.raw_response("-020041")
  end

  test "should format values for string variable with leading zero" do
    formatter = Formatters.for(variables(:format_string_zip_code))
    assert_equal Formatters::DefaultFormatter, formatter.class
    assert_equal String, formatter.raw_response("020041").class
    # assert_equal "20041", formatter.raw_response(20041)                       # TODO: Numbers should be reformatted as strings.
    assert_equal "0", formatter.raw_response("0")
    assert_equal "020041", formatter.raw_response("020041")
    assert_equal "00020041", formatter.raw_response("00020041")
    assert_equal "+020041", formatter.raw_response("+020041")
    assert_equal "-020041", formatter.raw_response("-020041")
  end
end
