require 'test_helper'

class SheetsHelperTest < ActionView::TestCase

  test "should find diff between strings" do
    assert_equal [], find_diff(nil,nil)
    assert_equal [], find_diff('','')
    assert_equal [], find_diff('','b')
    assert_equal [false], find_diff('a','')
    assert_equal [false], find_diff('a','b')
    assert_equal [true], find_diff('a','a')
    assert_equal [true, true, true, false, true, true, true], find_diff('dogecat', 'dogcat')
    assert_equal [true, true, true], find_diff('dog', 'catdogcat')
    assert_equal [true, true, true], find_diff('cat', 'dogcat')
    assert_equal [false, false, false, true, true, true], find_diff('dogcat', 'cat')
    assert_equal [true, true, true, false, false, false], find_diff('catcat', 'cat')
  end

end
