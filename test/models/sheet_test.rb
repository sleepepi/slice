require 'test_helper'

class SheetTest < ActiveSupport::TestCase

  test "should hide variable only if branching logic evaluates to false" do
    assert_equal false, sheets(:one).show_variable?("1 == 0")
  end

  test "should show variable if branching logic is invalid" do
    assert_equal true, sheets(:one).show_variable?("abc")
    assert_equal true, sheets(:one).show_variable?("1/0")
  end

  test "should get sheet coverage" do
    assert_equal "complete",  sheets(:coverage_complete).coverage
    assert_equal "green",     sheets(:coverage_90).coverage
    assert_equal "yellow",    sheets(:coverage_70).coverage
    assert_equal "orange",    sheets(:coverage_50).coverage
    assert_equal "red",       sheets(:coverage_30).coverage
    assert_equal "blank",     sheets(:coverage_0).coverage
  end

  test "should get sheet color" do
    assert_equal 0, /^#([0-9abcdef]){6}$/ =~ sheets(:coverage_complete).color
    assert_equal 0, /^#([0-9abcdef]){6}$/ =~ sheets(:coverage_90).color
    assert_equal 0, /^#([0-9abcdef]){6}$/ =~ sheets(:coverage_70).color
    assert_equal 0, /^#([0-9abcdef]){6}$/ =~ sheets(:coverage_50).color
    assert_equal 0, /^#([0-9abcdef]){6}$/ =~ sheets(:coverage_30).color
    assert_equal 0, /^#([0-9abcdef]){6}$/ =~ sheets(:coverage_0).color
  end

  test "sheet completion should be based on non hidden responses" do
    assert_equal 50, sheets(:filled_out_half_visible).percent
    assert_equal 100, sheets(:filled_out_all_visible).percent
    assert_equal 100, sheets(:filled_out_entire_sheet).percent
    assert_equal 66, sheets(:all_visible_not_all_answered).percent
    assert_equal 0, sheets(:hidden_response_answered).percent
  end

  test "get max grids position" do
    assert_equal 1, sheets(:has_grid).max_grids_position
  end

end
