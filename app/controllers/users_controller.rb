# frozen_string_literal: true

# Allows users to set settings, search for other users
# Allows admins to review existing accounts
class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_system_admin, only: [:new, :create, :edit, :update, :destroy]
  before_action :find_user_or_redirect, only: [:show, :edit, :update, :destroy]

  def index
    unless current_user.system_admin? || params[:format] == 'json'
      redirect_to root_path, alert: 'You do not have sufficient privileges to access that page.'
      return
    end

    @order = scrub_order(User, params[:order], 'users.current_sign_in_at desc')
    @users = User.current.search(params[:search] || params[:q]).order(@order).page(params[:page]).per(40)
  end

  # get JSON
  def invite
    @users = current_user.associated_users.search(params[:q]).order('last_name, first_name').limit(10)
    render json: @users.collect { |u| { value: u.email, name: u.name } }
  end

  def show
  end

  # def new
  #   @user = User.new
  # end

  def edit
  end

  # # This is in registrations_controller.rb
  # def create
  # end

  def update
    if @user.update(user_params)
      @user.update_column :system_admin, params[:user][:system_admin]
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

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
      :first_name, :last_name, :email, :theme, :beta_enabled, :emails_enabled
    )
  end
end
