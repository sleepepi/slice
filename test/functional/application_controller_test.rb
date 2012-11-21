require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  setup do
    # Nothing
  end

  test "should parse time" do
    assert_equal "12:00:00", @controller.send(:parse_time, "12pm")
  end

  test "should parse invalid time" do
    assert_equal "", @controller.send(:parse_time, "abc")
  end

  test "should make latex safe" do
    assert_equal '\\textbackslash', @controller.send(:latex_safe, "\\")
    assert_equal '\\#', @controller.send(:latex_safe, "#")
    assert_equal '\\$', @controller.send(:latex_safe, "$")
    # assert_equal "\\&", @controller.send(:latex_safe, "&") # Not currently sure how to correctly escape '&' for LaTeX
    # assert_equal '\\~{}', @controller.send(:latex_safe, "~")
    # assert_equal '\\_', @controller.send(:latex_safe, "_")
    # assert_equal '\\^{}', @controller.send(:latex_safe, "^")
    # assert_equal '\\{', @controller.send(:latex_safe, "{")
    # assert_equal '\\}', @controller.send(:latex_safe, "}")
    # assert_equal '\\textless{}', @controller.send(:latex_safe, "<")
    # assert_equal '\\textgreater{}', @controller.send(:latex_safe, ">")
  end

end
