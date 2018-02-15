# frozen_string_literal: true

# Allows projects preferences to be set.
class ProjectPreferencesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_project_or_redirect
  before_action :find_or_create_project_preference

  # PATCH /preferences/update?project_id=1
  def update
    @project_preference.update project_preference_params
  end

  private

  def project_preference_params
    params.permit(:archived, :emails_enabled)
  end

  def find_or_create_project_preference
    @project_preference = @project.project_preferences.where(user_id: current_user.id).first_or_create
  end
end
