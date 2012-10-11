require 'test_helper'

class SheetEmailsControllerTest < ActionController::TestCase
  setup do
    login(users(:valid))
    @sheet_email = sheet_emails(:one)
  end

  test "should show sheet email" do
    get :show, id: @sheet_email
    assert_not_nil assigns(:sheet_email)
    assert_response :success
  end

end
