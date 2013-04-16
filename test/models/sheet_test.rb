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

end
