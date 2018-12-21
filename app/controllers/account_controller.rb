# frozen_string_literal: true

# Allows a user to view and update account preferences.
class AccountController < ApplicationController
  before_action :authenticate_user!
  before_action :check_invite_tokens, only: :dashboard

  # GET /dashboard
  def dashboard
    @projects = current_user.all_dashboard_projects
                            .by_preferences(current_user.id).unarchived
                            .order(Arel.sql("position, name"))
                            .page(params[:page]).per(Project::PER_PAGE)
    redirect_to @projects.first if current_user.all_dashboard_projects.count == 1
  end

  private

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
