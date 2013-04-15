require 'test_helper'

class SheetTest < ActiveSupport::TestCase

  test "should get response file url" do
    assert_equal "", sheets(:all_variables).response_file_url(variables(:file))
  end

end
