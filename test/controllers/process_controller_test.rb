# frozen_string_literal: true

require "test_helper"

# Tests to assure project variables can be formatted and validated.
class ProcessControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:one)
    @calculated = variables(:calculated)
    @date = variables(:date)
  end

  test "should get format" do
    post process_variable_format_url(@project, @calculated, value: "26.2585252566313", format: "json")
    json = JSON.parse(response.body)
    assert_equal "26.26", json["value"]["formatted"]
    assert_equal "26.2585252566313", json["value"]["raw"]
    assert_response :success
  end

  test "should validate variable" do
    post process_variable_validate_url(@project, @date, format: "json"), params: {
      value: { month: "1", day: "1", year: "2000" }
    }
    json = JSON.parse(response.body)
    assert_equal "in_soft_range", json["status"]
    assert_equal "January 1, 2000", json["formatted_value"]
    assert_equal "", json["message"]
    assert_response :success
  end

  test "should validate variable with blank fields" do
    post process_variable_validate_url(@project, @date, format: "json"), params: {
      value: { month: "", day: "", year: "" }
    }
    json = JSON.parse(response.body)
    assert_equal "blank", json["status"]
    assert_nil json["formatted_value"]
    assert_equal "", json["message"]
    assert_response :success
  end

  test "should validate return out of range for variable" do
    post process_variable_validate_url(@project, @date, format: "json"), params: {
      value: { month: "12", day: "31", year: "1989" }
    }
    json = JSON.parse(response.body)
    assert_equal "out_of_range", json["status"]
    assert_equal "December 31, 1989", json["formatted_value"]
    assert_equal "Date outside of range.", json["message"]
    assert_response :success
  end

  test "should validate return invalid for variable" do
    post process_variable_validate_url(@project, @date, format: "json"), params: {
      value: { month: "2", day: "31", year: "2000" }
    }
    json = JSON.parse(response.body)
    assert_equal "invalid", json["status"]
    assert_nil json["formatted_value"]
    assert_equal "Not a valid date.", json["message"]
    assert_response :success
  end

  test "should validate return inside hard range for variable" do
    post process_variable_validate_url(@project, @date, format: "json"), params: {
      value: { month: "6", day: "15", year: "1995" }
    }
    json = JSON.parse(response.body)
    assert_equal "in_hard_range", json["status"]
    assert_equal "June 15, 1995", json["formatted_value"]
    assert_equal "Date outside of soft range.", json["message"]
    assert_response :success
  end
end
