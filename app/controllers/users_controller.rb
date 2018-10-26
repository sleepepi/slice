# frozen_string_literal: true

# Allows users to set settings, search for other users.
# Allows admins to review existing accounts.
class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin!
  before_action :find_user_or_redirect, only: [:show, :edit, :update, :destroy]

  layout "layouts/full_page_sidebar"

  # GET /users
  def index
    scope = User.current.search_any_order(params[:search])
    @users = scope_order(scope).page(params[:page]).per(40)
  end

  # # GET /users/1
  # def show
  # end

  # # GET /users/1/edit
  # def edit
  # end

  # PATCH /users/1
  def update
    if @user.update(user_params)
      redirect_to @user, notice: "User was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
    redirect_to users_path
  end

  private

  def find_user_or_redirect
    @user = User.current.find_by(id: params[:id])
    redirect_without_user
  end

  def redirect_without_user
    return if @user
    empty_response_or_root_path users_path
  end

  def user_params
    params.require(:user).permit(
      :full_name, :email, :theme, :emails_enabled, :admin
    )
  end

  def scope_order(scope)
    @order = scrub_order(User, params[:order], "users.current_sign_in_at desc")
    scope.order(@order)
  end
end
