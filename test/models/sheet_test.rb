require 'test_helper'

class SheetTest < ActiveSupport::TestCase

  test "should get response file url" do
    assert_equal "", sheets(:all_variables).response_file_url(variables(:file))
  end

  test "should not allow the same authentication_token to be assigned to two sheets" do
    authentication_token = SecureRandom.hex(32)
    assert_equal SheetEmail, sheets(:one).send_external_email!(users(:valid), "test@example.com", "Additional Text", authentication_token).class
    assert_equal NilClass, sheets(:two).send_external_email!(users(:valid), "test@example.com", "Additional Text", authentication_token).class
  end

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

end
