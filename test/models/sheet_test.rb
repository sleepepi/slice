# frozen_string_literal: true

require "test_helper"

# Test individual sheet methods.
class SheetTest < ActiveSupport::TestCase
  test "should hide variable only if branching logic evaluates to false" do
    assert_equal false, sheets(:one).show_design_option?("1 == 0")
  end

  test "should show variable if branching logic is invalid" do
    assert_equal true, sheets(:one).show_design_option?("abc")
    assert_equal true, sheets(:one).show_design_option?("1/0")
  end

  test "should get sheet coverage" do
    assert_equal "coverage-100", sheets(:coverage_complete).coverage
    assert_equal "coverage-90", sheets(:coverage_90).coverage
    assert_equal "coverage-70", sheets(:coverage_70).coverage
    assert_equal "coverage-50", sheets(:coverage_50).coverage
    assert_equal "coverage-30", sheets(:coverage_30).coverage
    assert_equal "coverage-0", sheets(:coverage_0).coverage
  end

  test "should get sheet color" do
    assert_equal "#337ab7", sheets(:coverage_complete).color
    assert_equal "#5cb85c", sheets(:coverage_90).color
    assert_equal "#f0ad4e", sheets(:coverage_70).color
    assert_equal "#f0ad4e", sheets(:coverage_50).color
    assert_equal "#d9534f", sheets(:coverage_30).color
    assert_equal "#777777", sheets(:coverage_0).color
  end

  test "sheet completion should be based on non hidden responses" do
    sheets(:filled_out_half_visible).update_coverage!
    sheets(:filled_out_all_visible).update_coverage!
    sheets(:filled_out_entire_sheet).update_coverage!
    sheets(:all_visible_not_all_answered).update_coverage!
    sheets(:hidden_response_answered).update_coverage!
    assert_equal 50, sheets(:filled_out_half_visible).percent
    assert_equal 100, sheets(:filled_out_all_visible).percent
    assert_equal 100, sheets(:filled_out_entire_sheet).percent
    assert_equal 66, sheets(:all_visible_not_all_answered).percent
    assert_equal 0, sheets(:hidden_response_answered).percent
  end

  test "sheet of empty design should show as completed" do
    sheets(:coverage_empty).update_coverage!
    assert_equal 0, sheets(:coverage_empty).response_count
    assert_equal 0, sheets(:coverage_empty).total_response_count
    assert_equal 100, sheets(:coverage_empty).percent
  end

  test "get max grids position" do
    assert_equal 1, sheets(:has_grid).max_grids_position
  end
end
