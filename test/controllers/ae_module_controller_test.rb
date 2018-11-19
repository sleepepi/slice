require "test_helper"

class AeModuleControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:aes)
    @owner = users(:aes_owner)
  end

  test "should get dashboard" do
    login(@owner)
    get ae_module_dashboard_url(@project)
    assert_response :success
  end
end
