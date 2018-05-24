# frozen_string_literal: true

require "test_helper"

SimpleCov.command_name "test:controllers"

# Tests to make sure users can access account settings, and reset password, and
# that admins can edit and update existing users.
class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:regular)
  end

  test "should get index as admin" do
    login(users(:admin))
    get :index
    assert_not_nil assigns(:users)
    assert_response :success
  end

  test "should get index for autocomplete" do
    login(users(:regular))
    get :index, format: "json"
    assert_not_nil assigns(:users)
    assert_response :success
  end

  test "should not get index for non-system admin" do
    login(users(:regular))
    get :index
    assert_nil assigns(:users)
    assert_equal "You do not have sufficient privileges to access that page.", flash[:alert]
    assert_redirected_to root_path
  end

  test "should not get index with pagination for non-system admin" do
    login(users(:regular))
    get :index, format: "js"
    assert_nil assigns(:users)
    assert_equal "You do not have sufficient privileges to access that page.", flash[:alert]
    assert_redirected_to root_path
  end

  test "should get invite for regular user" do
    login(users(:regular))
    get :invite, params: { q: "associated" }
    users_json = JSON.parse(response.body)
    assert_equal "associated@example.com", users_json.first["value"]
    assert_equal "Associated User", users_json.first["name"]
    assert_response :success
  end

  test "should show user as admin" do
    login(users(:admin))
    get :show, params: { id: @user }
    assert_response :success
  end

  test "should get edit as admin" do
    login(users(:admin))
    get :edit, params: { id: @user }
    assert_response :success
  end

  test "should not get edit as regular user" do
    login(users(:regular))
    get :edit, params: { id: @user }
    assert_redirected_to root_path
  end

  test "should update user as admin" do
    login(users(:admin))
    patch :update, params: {
      id: @user,
      user: {
        full_name: "FirstName LastName",
        email: "regular_updated_email@example.com",
        admin: "0"
      }
    }
    assert_redirected_to @user
  end

  test "should not update user with blank full name" do
    login(users(:admin))
    patch :update, params: {
      id: @user, user: { full_name: "" }
    }
    assert_not_nil assigns(:user)
    assert_template "edit"
    assert_response :success
  end

  test "should not update user with invalid id" do
    login(users(:admin))
    patch :update, params: {
      id: -1,
      user: {
        full_name: "FirstName LastName",
        email: "regular_updated_email@example.com",
        admin: "0"
      }
    }
    assert_redirected_to users_path
  end

  test "should destroy user as admin" do
    login(users(:admin))
    assert_difference("User.current.count", -1) do
      delete :destroy, params: { id: @user }
    end
    assert_redirected_to users_path
  end
end
