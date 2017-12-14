# frozen_string_literal: true

# Allows a user to view and update account preferences.
class AccountController < ApplicationController
  before_action :authenticate_user!
  before_action :check_invite_tokens, only: :dashboard

  # GET /dashboard
  def dashboard
    @projects = current_user.all_viewable_and_site_projects
                            .by_favorite(current_user.id).unarchived
                            .order(Arel.sql("(favorited IS NULL or favorited = 'f') ASC, position, name"))
                            .page(params[:page]).per(Project::PER_PAGE)
    @favorited_projects = @projects.where(project_preferences: { favorited: true })
    @current_projects = @projects.where(project_preferences: { favorited: [false, nil] }).reorder(Arel.sql("lower(name) asc"))
    redirect_to @projects.first if current_user.all_viewable_and_site_projects.count == 1
  end

  # PATCH /change_password
  def change_password
    if current_user.valid_password?(params[:user][:current_password])
      if current_user.reset_password(params[:user][:password], params[:user][:password_confirmation])
        bypass_sign_in current_user
        redirect_to settings_path, notice: "Your password has been changed."
      else
        render :settings
      end
    else
      current_user.errors.add :current_password, "is invalid"
      render :settings
    end
  end

  # GET /settings
  # def settings
  # end

  # POST /settings
  def update_settings
    current_user.update user_params
    redirect_to settings_path, notice: "Settings saved."
  end

  private

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :email, :emails_enabled, :theme, :sound_enabled
    )
  end

  def check_invite_tokens
    if session[:invite_token].present?
      redirect_to accept_project_users_path
    elsif session[:site_invite_token].present?
      @site_user = SiteUser.find_by(invite_token: session[:site_invite_token])
      if @site_user
        redirect_to accept_project_site_users_path(@site_user.project)
      else
        session[:site_invite_token] = nil
        flash[:alert] = "Invalid invitation token."
      end
    end
  end
end
