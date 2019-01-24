# frozen_string_literal: true

# Allows a user to view and update account preferences.
class AccountController < ApplicationController
  before_action :authenticate_user!

  # GET /dashboard
  def dashboard
    @projects = current_user.all_dashboard_projects
                            .by_preferences(current_user.id).unarchived
                            .order(Arel.sql("position, name"))
                            .page(params[:page]).per(Project::PER_PAGE)
    @invites = current_user.current_invites
    redirect_to @projects.first if current_user.all_dashboard_projects.count == 1 && @invites.blank?
  end
end
