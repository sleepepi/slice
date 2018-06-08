# frozen_string_literal: true

require "test_helper"

# Tests to assure handoffs can be completed by public users.
class HandoffControllerTest < ActionDispatch::IntegrationTest
  setup do
    @launched = handoffs(:one)
    @completed = handoffs(:completed)
    @project = projects(:one)
  end

  test "should get start as public user" do
    get handoff_start_url(@project, @launched)
    assert_response :success
  end

  test "should not get start for completed handoff as public user" do
    get handoff_start_url(@project, @completed)
    assert_redirected_to handoff_completed_url
  end

  test "should get design as public user" do
    get handoff_design_url(@project, @launched, @launched.first_design)
    assert_response :success
  end

  test "should not get design for completed handoff as public user" do
    get handoff_design_url(@project, @completed, @completed.first_design)
    assert_redirected_to handoff_completed_url
  end

  test "should save design as public user" do
    post handoff_save_url(@project, @launched, designs(:one))
    assert_redirected_to handoff_design_url(@project, @launched, designs(:sections_and_variables))
  end

  test "should save design as public user and set handoff as completed" do
    assert_difference("Handoff.where(token: nil).count") do
      post handoff_save_url(@project, @launched, designs(:sections_and_variables))
    end
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:sheet).last_edited_at
    assert_redirected_to handoff_completed_url
  end

  test "should not save design as public user if required fields are left blank" do
    post handoff_save_url(
      projects(:three),
      handoffs(:required_forms),
      designs(:admin_public_design_with_required_fields)
    ), params: {
      variables: { variables(:public_autocomplete).id.to_s => "" }
    }
    assert_template "design"
    assert_response :success
  end

  test "should save design as public user if required fields is set" do
    post handoff_save_url(
      projects(:three),
      handoffs(:required_forms),
      designs(:admin_public_design_with_required_fields)
    ), params: {
      variables: { variables(:public_autocomplete).id.to_s => "Dog" }
    }
    assert_redirected_to handoff_completed_url
  end

  test "should get completed handoff as public user" do
    get handoff_completed_url
    assert_response :success
  end
end
