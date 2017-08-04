# frozen_string_literal: true

# Provides common methods used by all API controllers.
class Api::V1::BaseController < ApplicationController
  prepend_before_action { request.env["devise.skip_timeout"] = true }
  skip_before_action :verify_authenticity_token

  private

  def find_project_or_redirect
    authenticate_project_from_token!
    head :no_content unless @project
  end

  def authenticate_project_from_token!
    (project, auth_token) = parse_auth_token
    # Devise.secure_compare is used to mitigate timing attacks.
    return unless project && Devise.secure_compare(project.authentication_token, auth_token)
    @project = project
  end

  def parse_auth_token
    project_id = parse_project_id
    auth_token = params[:authentication_token].to_s.gsub(/^#{project_id}-/, "")
    project = project_id && Project.current.find_by(id: project_id)
    [project, auth_token]
  end

  def parse_project_id
    params[:authentication_token].to_s.split("-").first.to_s.gsub(/[^a-z0-9]/i, "")
  end

  def find_subject_or_redirect
    @subject = @project.subjects.find_by(id: params[:id])
    head :no_content unless @subject
  end
end
