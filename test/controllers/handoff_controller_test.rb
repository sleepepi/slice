# frozen_string_literal: true

require 'test_helper'

# Tests to assure handoffs can be completed by public users
class HandoffControllerTest < ActionController::TestCase
  setup do
    @launched = handoffs(:one)
    @completed = handoffs(:completed)
    @project = projects(:one)
  end

  test 'should get start as public user' do
    get :start, params: { project: @project, handoff: @launched }
    assert_response :success
  end

  test 'should not get start for completed handoff as public user' do
    get :start, params: { project: @project, handoff: @completed }
    assert_redirected_to handoff_completed_path
  end

  test 'should get design as public user' do
    get :design, params: {
      project: @project, handoff: @launched, design: @launched.first_design
    }
    assert_response :success
  end

  test 'should not get design for completed handoff as public user' do
    get :design, params: {
      project: @project, handoff: @completed, design: @completed.first_design
    }
    assert_redirected_to handoff_completed_path
  end

  test 'should save design as public user' do
    post :save, params: {
      project: @project, handoff: @launched, design: designs(:one)
    }
    assert_redirected_to handoff_design_path(@project, @launched, designs(:sections_and_variables))
  end

  test 'should save design as public user and set handoff as completed' do
    assert_difference('Handoff.where(token: nil).count') do
      post :save, params: {
        project: @project, handoff: @launched, design: designs(:sections_and_variables)
      }
    end
    assert_not_nil assigns(:sheet)
    assert_not_nil assigns(:sheet).last_edited_at
    assert_redirected_to handoff_completed_path
  end

  test 'should not save design as public user if required fields are left blank' do
    post :save, params: {
      project: projects(:three), handoff: handoffs(:required_forms),
      design: designs(:admin_public_design_with_required_fields),
      variables: { variables(:public_autocomplete).id.to_s => '' }
    }
    assert_template 'design'
    assert_response :success
  end

  test 'should save design as public user if required fields is set' do
    post :save, params: {
      project: projects(:three), handoff: handoffs(:required_forms),
      design: designs(:admin_public_design_with_required_fields),
      variables: { variables(:public_autocomplete).id.to_s => 'Dog' }
    }
    assert_redirected_to handoff_completed_path
  end

  test 'should get completed handoff as public user' do
    get :completed
    assert_response :success
  end
end
