require 'test_helper'

class VariableTest < ActiveSupport::TestCase
  test "should get response file url" do
    assert_equal "", variables(:file).response_file_url(sheets(:all_variables))
  end
end
