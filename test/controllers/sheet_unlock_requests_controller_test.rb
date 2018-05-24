# frozen_string_literal: true

require 'test_helper'

# Tests to assure that site editors can submit sheet unlock requests.
class SheetUnlockRequestsControllerTest < ActionController::TestCase
  setup do
    @project = projects(:auto_lock)
    @locked_sheet = sheets(:auto_lock)
    @sheet_unlock_request = sheet_unlock_requests(:one)
    @project_editor = users(:regular)
    @site_editor = users(:auto_lock_site_one_editor)
  end

  test 'should create sheet unlock request' do
    login(@site_editor)
    assert_difference('SheetUnlockRequest.count') do
      post :create, params: {
        project_id: @project, sheet_id: @locked_sheet,
        sheet_unlock_request: { reason: 'Transcription Error' }
      }, format: 'js'
    end
    assert_template 'create'
    assert_response :success
  end

  test 'should not create sheet unlock request without reason' do
    login(@site_editor)
    assert_difference('SheetUnlockRequest.count', 0) do
      post :create, params: {
        project_id: @project, sheet_id: @locked_sheet,
        sheet_unlock_request: { reason: '' }
      }, format: 'js'
    end
    assert_template 'new'
    assert_response :success
  end

  test 'should destroy sheet unlock request as site editor' do
    login(@site_editor)
    assert_difference('SheetUnlockRequest.current.count', -1) do
      delete :destroy, params: {
        project_id: @project, sheet_id: @locked_sheet,
        id: @sheet_unlock_request
      }
    end
    assert_redirected_to [@project, @locked_sheet]
  end

  test 'should destroy sheet unlock request as project editor' do
    login(@project_editor)
    assert_difference('Notification.count', -1) do
      assert_difference('SheetUnlockRequest.current.count', -1) do
        delete :destroy, params: {
          project_id: @project, sheet_id: @locked_sheet,
          id: @sheet_unlock_request
        }
      end
    end
    assert_redirected_to [@project, @locked_sheet]
  end
end
