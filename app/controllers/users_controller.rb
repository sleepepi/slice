# frozen_string_literal: true

# Allows users to set settings, search for other users.
# Allows admins to review existing accounts.
class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_system_admin, only: [:new, :create, :edit, :update, :destroy]
  before_action :find_user_or_redirect, only: [:show, :edit, :update, :destroy]

  # GET /users
  def index
    unless current_user.system_admin? || params[:format] == "json"
      redirect_to root_path, alert: "You do not have sufficient privileges to access that page."
      return
    end
    scope = User.current
    scope = scope_filter(scope)
    @users = scope_order(scope).page(params[:page]).per(40)
  end

  # GET /users/invite
  def invite
    @users = current_user.associated_users.search(params[:q]).order(:full_name).limit(10)
    render json: @users.collect { |u| { value: u.email, name: u.full_name } }
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
      @user.update_column :system_admin, params[:user][:system_admin]
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
      :full_name, :email, :theme, :emails_enabled
    )
  end

  def scope_filter(scope)
    scope.search(params[:search] || params[:q])
  end

  def scope_order(scope)
    @order = scrub_order(User, params[:order], "users.current_sign_in_at desc")
    scope.order(@order)
  end
end
