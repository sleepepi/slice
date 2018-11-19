# frozen_string_literal: true

require "test_helper"

class AeModule::AdminsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:aes)
    @review_admin = users(:aes_review_admin)
  end

  test "should get dashboard" do
    login(@review_admin)
    get ae_module_admins_dashboard_url(@project)
    assert_response :success
  end
end
