require 'test_helper'

class ExportTest < ActiveSupport::TestCase

  test "generate an export with a sheet_scope" do
    exports(:two).generate_export!(projects(:one).sheets)
    assert_equal 'ready', exports(:two).status
  end

end
