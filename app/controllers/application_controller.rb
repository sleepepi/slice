# frozen_string_literal: true

# Main web application controller for Slice website.
# Other controllers inherit from this as a base class.
# This controller also handles several static pages in views/application.
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token, if: :devise_login?
  before_action :configure_permitted_parameters, if: :devise_controller?

  before_action :set_cache_buster
  before_action :set_language
  before_action :set_locale

  include DateAndTimeParser

  protected

  def devise_login?
    params[:controller] == "devise/sessions" && params[:action] == "create"
  end

  def check_admin!
    return if current_user.admin?
    redirect_to dashboard_path
  end

  def scrub_order(model, params_order, default_order)
    (params_column, params_direction) = params_order.to_s.strip.downcase.split(" ")
    direction = (params_direction == "desc" ? "desc" : nil)
    column_name = model.column_names.collect { |c| "#{model.table_name}.#{c}" }.find { |c| c == params_column }
    column_name.blank? ? default_order : [column_name, direction].compact.join(" ")
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(
      :sign_up,
      keys: [:full_name, :email, :password, :password_confirmation, :emails_enabled]
    )
  end

  def find_viewable_project_or_redirect(id = :project_id)
    @project = current_user.all_viewable_and_site_projects.find_by_param(params[id])
    project = Project.current.find_by_param(params[id])
    if project&.ae_admin?(current_user) || project&.ae_team?(current_user)
      redirect_to ae_module_adverse_events_path(project) unless @project
    else
      redirect_without_project
    end
  end

  def find_editable_project_or_redirect(id = :project_id)
    @project = current_user.all_projects.find_by_param(params[id])
    redirect_without_project
  end

  def find_editable_project_or_editable_site_or_redirect
    @project = current_user.all_sheet_editable_projects.find_by_param(params[:project_id])
    redirect_without_project
  end

  def redirect_without_project(path = root_path)
    empty_response_or_root_path(path) unless @project
  end

  def find_viewable_subject_or_redirect(id = :subject_id)
    @subject = current_user.all_viewable_subjects.includes(:project).where(project: @project).find_by(id: params[id])
    redirect_without_subject
  end

  def find_editable_subject_or_redirect(id = :subject_id)
    @subject = current_user.all_subjects.includes(:project).where(project: @project).find_by(id: params[id])
    redirect_without_subject
  end

  def redirect_without_subject
    empty_response_or_root_path(project_subjects_path(@project)) unless @subject
  end

  def redirect_blinded_users
    empty_response_or_root_path(@project) unless @project.unblinded?(current_user)
  end

  def empty_response_or_root_path(path = root_path)
    respond_to do |format|
      format.html { redirect_to path }
      format.js { head :ok }
      format.json { head :no_content }
      format.pdf { redirect_to path }
    end
  end

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def check_key_and_set_default_value(object, key, default_value)
    return unless params[object].key?(key) && params[object][key].blank?
    params[object][key] = default_value
  end

  def parse_date_if_key_present(object, key)
    return unless params[object].key?(key)
    params[object][key] = parse_date(params[object][key]) if params[object].key?(key)
  end

  # Expects an "Uploader" type class, ex: uploader = @project.logo
  # disposition: "attachment" | "inline"
  # type: "application/pdf", etc. MIME::Types
  def send_file_if_present(uploader, disposition: "attachment", type: nil)
    if ENV["AMAZON"].to_s == "true"
      redirect_to uploader.url(query: { "response-content-disposition" => disposition }) #, allow_other_host: true
    else
      if uploader.present?
        if type.present?
          send_file uploader.path, disposition: disposition, type: type
        else
          send_file uploader.path, disposition: disposition
        end
      else
        head :ok
      end
    end
  end

  def send_profile_picture_if_present(object, thumb: false)
    profile_picture = if thumb
      object&.profile_picture&.thumb
    else
      object&.profile_picture
    end

    if ENV["AMAZON"].to_s == "true"
      if profile_picture&.url.present?
        redirect_to profile_picture.url(query: { "response-content-disposition" => "inline" }) #, allow_other_host: true
      else
        head :ok
      end
    else
      send_file_if_present profile_picture, disposition: "inline"
    end
  end

  def set_language
    World.language = params[:language].presence&.to_sym || World.default_language
  end

  def set_locale
    I18n.locale = params[:locale].presence || I18n.default_locale
  end

  # def default_url_options
  #   return {} if I18n.locale == I18n.default_locale
  #   { locale: I18n.locale }
  # end
end
