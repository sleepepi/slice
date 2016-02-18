# frozen_string_literal: true

# Allows users to set settings, search for other users
# Allows admins to review existing accounts
class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_system_admin, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :redirect_without_user, only: [:show, :edit, :update, :destroy]

  def settings
  end

  def update_settings
    notifications = {}
    email_settings = User::EMAILABLES.collect { |emailable, description| emailable.to_s } + current_user.all_viewable_projects.collect { |p| User::EMAILABLES.collect{|emailable, description| "project_#{p.id}_#{emailable.to_s}" } }.flatten

    email_settings.each do |email_setting|
      notifications[email_setting] = (params[:email].present? && params[:email][email_setting] == '1')
    end

    current_user.update email_notifications: notifications, emails_enabled: params[:user][:emails_enabled]
    redirect_to settings_path, notice: 'Email settings saved.'
  end

  def change_password
    if current_user.valid_password?(params[:user][:current_password])
      if current_user.reset_password(params[:user][:password], params[:user][:password_confirmation])
        sign_in current_user, bypass: true
        redirect_to settings_path, notice: 'Your password has been changed.'
      else
        render :settings
      end
    else
      current_user.errors.add :current_password, 'is invalid'
      render :settings
    end
  end

  def index
    unless current_user.system_admin? || params[:format] == 'json'
      redirect_to root_path, alert: 'You do not have sufficient privileges to access that page.'
      return
    end

    @order = scrub_order(User, params[:order], 'users.current_sign_in_at DESC')
    @users = User.current.search(params[:search] || params[:q]).order(@order).page(params[:page]).per(40)

    respond_to do |format|
      format.html
      format.json do # TODO: Put into jbuilder instead!
        render json: params[:q].to_s.split(',').collect{ |u| (u.strip.downcase == 'me') ? { name: current_user.name, id: current_user.name } : { name: u.strip.titleize, id: u.strip.titleize } } + @users.collect{ |u| { name: u.name, id: u.name } }
      end
    end
  end

  # get JSON
  def invite
    @users = current_user.associated_users.search(params[:q]).order('last_name, first_name').limit(10)
    render json: @users.collect{ |u| { value: u.email, name: u.name  } }
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

  def update_theme
    if current_user.update(user_params)
      redirect_to settings_path, notice: 'Settings were successfully updated.'
    else
      redirect_to settings_path, alert: 'Settings were not successfully updated.'
    end
  end

  def update
    if @user.update(user_params)
      @user.update_column :system_admin, params[:user][:system_admin]
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path
  end

  private

  def set_user
    @user = User.current.find_by_id(params[:id])
  end

  def redirect_without_user
    empty_response_or_root_path(users_path) unless @user
  end

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :email, :theme, :beta_enabled, :emails_enabled
    )
  end
end
