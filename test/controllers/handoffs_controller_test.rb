require 'test_helper'

class HandoffsControllerTest < ActionController::TestCase
  setup do
    @handoff = handoffs(:one)
  end

  # test 'should get index' do
  #   get :index
  #   assert_response :success
  #   assert_not_nil assigns(:handoffs)
  # end

  test 'should get new' do
    skip
    get :new
    assert_response :success
  end

  test 'should create handoff' do
    skip
    assert_difference('Handoff.count') do
      post :create, handoff: { event_id: @handoff.event_id, project_id: @handoff.project_id, subject_id: @handoff.subject_id, token: @handoff.token, user_id: @handoff.user_id }
    end

    assert_redirected_to handoff_path(assigns(:handoff))
  end

  # test 'should show handoff' do
  #   get :show, id: @handoff
  #   assert_response :success
  # end

  # test 'should get edit' do
  #   get :edit, id: @handoff
  #   assert_response :success
  # end

  # test 'should update handoff' do
  #   patch :update, id: @handoff, handoff: { event_id: @handoff.event_id, project_id: @handoff.project_id, subject_id: @handoff.subject_id, token: @handoff.token, user_id: @handoff.user_id }
  #   assert_redirected_to handoff_path(assigns(:handoff))
  # end

  # test 'should destroy handoff' do
  #   assert_difference('Handoff.count', -1) do
  #     delete :destroy, id: @handoff
  #   end

  #   assert_redirected_to handoffs_path
  # end
end
