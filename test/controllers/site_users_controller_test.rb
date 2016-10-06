# frozen_string_literal: true

require 'test_helper'

# Tests to make sure users can be successfully invited to project sites
class SiteUsersControllerTest < ActionController::TestCase
  setup do
    @project = projects(:one)
    @project_editor = users(:project_one_editor)
    @site_user = site_users(:one)
    @unblinded_member = site_users(:site_editor)
    @blinded_member = site_users(:site_editor_blinded)
  end

  test 'should resend site invitation' do
    login(users(:valid))
    post :resend, params: { id: @site_user, project_id: @project }, format: 'js'
    assert_not_nil assigns(:site_user)
    assert_not_nil assigns(:site)
    assert_template 'update'
    assert_response :success
  end

  test 'should not resend site invitation with invalid id' do
    login(users(:valid))
    post :resend, params: { id: -1, project_id: @project }, format: 'js'
    assert_nil assigns(:site_user)
    assert_nil assigns(:site)
    assert_template nil
    assert_response :success
  end

  test 'should get invite for logged in site user' do
    login(users(:two))
    get :invite, params: { site_invite_token: site_users(:invited).invite_token }
    assert_equal session[:site_invite_token], site_users(:invited).invite_token
    assert_redirected_to accept_project_site_users_path(assigns(:site_user).project)
  end

  test 'should get invite for public site user' do
    get :invite, params: { site_invite_token: site_users(:invited).invite_token }
    assert_equal session[:site_invite_token], site_users(:invited).invite_token
    assert_redirected_to new_user_session_path
  end

  test 'should not get invite for logged in site user with invalid token' do
    login(users(:two))
    get :invite, params: { site_invite_token: 'INVALID' }
    assert_nil session[:site_invite_token]
    assert_redirected_to root_path
  end

  test 'should accept site user' do
    login(users(:two))
    session[:site_invite_token] = site_users(:invited).invite_token
    get :accept, params: { project_id: @project }
    assert_not_nil assigns(:site_user)
    assert_equal users(:two), assigns(:site_user).user
    assert_equal 'You have been successfully been added to the project.', flash[:notice]
    assert_redirected_to assigns(:site_user).site.project
  end

  test 'should accept existing site user' do
    login(users(:valid))
    session[:site_invite_token] = site_users(:accepted_viewer_invite).invite_token
    get :accept, params: { project_id: @project }
    assert_not_nil assigns(:site_user)
    assert_equal users(:valid), assigns(:site_user).user
    assert_equal "You have already been added to #{assigns(:site_user).site.name}.", flash[:notice]
    assert_redirected_to assigns(:site_user).site.project
  end

  test 'should not accept invalid token for site user' do
    login(users(:valid))
    session[:site_invite_token] = 'imaninvalidtoken'
    get :accept, params: { project_id: @project }
    assert_nil assigns(:site_user)
    assert_equal 'Invalid invitation token.', flash[:alert]
    assert_redirected_to root_path
  end

  test 'should not accept site user if invite token is already claimed' do
    login(users(:two))
    session[:site_invite_token] = 'validintwo'
    get :accept, params: { project_id: @project }
    assert_not_nil assigns(:site_user)
    assert_not_equal users(:two), assigns(:site_user).user
    assert_equal 'This invite has already been claimed.', flash[:alert]
    assert_redirected_to root_path
  end

  test 'should set site user as blinded' do
    login(@project_editor)
    assert_difference('SiteUser.where(unblinded: true).count', -1) do
      patch :update, params: {
        project_id: @project.id, id: @unblinded_member, unblinded: '0'
      }, format: 'js'
    end
    assert_template 'update'
    assert_response :success
  end

  test 'should set site user as unblinded' do
    login(@project_editor)
    assert_difference('SiteUser.where(unblinded: false).count', -1) do
      patch :update, params: {
        project_id: @project.id, id: @blinded_member, unblinded: '1'
      }, format: 'js'
    end
    assert_template 'update'
    assert_response :success
  end

  test 'should destroy site_user' do
    login(users(:valid))
    assert_difference('SiteUser.count', -1) do
      delete :destroy, params: {
        id: @site_user, project_id: @project
      }, format: 'js'
    end
    assert_not_nil assigns(:site_user)
    assert_not_nil assigns(:site)
    assert_template 'projects/members'
    assert_response :success
  end

  test 'should not destroy site_user as a site user' do
    login(users(:site_one_viewer))
    assert_difference('SiteUser.count', 0) do
      delete :destroy, params: {
        id: @site_user, project_id: @project
      }, format: 'js'
    end
    assert_not_nil assigns(:site_user)
    assert_nil assigns(:site)
    assert_response :success
  end

  test 'should destroy site_user if signed in user is the selected site user' do
    login(users(:site_one_viewer))
    assert_difference('SiteUser.count', -1) do
      delete :destroy, params: {
        id: site_users(:site_viewer), project_id: @project
      }, format: 'js'
    end
    assert_not_nil assigns(:site_user)
    assert_not_nil assigns(:site)
    assert_template 'projects/members'
    assert_response :success
  end
end
