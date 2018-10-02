# frozen_string_literal: true

require "test_helper"

# Test to assure admins can view Slice Expression Engine runs.
class EngineRunsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @engine_run = engine_runs(:one)
  end

  test "should get index" do
    login(@admin)
    get admin_engine_runs_url
    assert_response :success
  end

  test "should show engine run" do
    login(@admin)
    get admin_engine_run_url(@engine_run)
    assert_response :success
  end

  test "should destroy engine run" do
    login(@admin)
    assert_difference("EngineRun.count", -1) do
      delete admin_engine_run_url(@engine_run)
    end
    assert_redirected_to admin_engine_runs_url
  end
end
