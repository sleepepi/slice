# frozen_string_literal: true

# Main web application controller for Slice website
# Other controllers inherit from this as a base class
# This controller also handles several static pages in views/application
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout 'layouts/application_custom'

  before_action :set_cache_buster

  include DateAndTimeParser

  protected

  def check_system_admin
    return if current_user.system_admin?
    redirect_to root_path, alert: 'You do not have sufficient privileges to access that page.'
  end

  def scrub_order(model, params_order, default_order)
    (params_column, params_direction) = params_order.to_s.strip.downcase.split(' ')
    direction = (params_direction == 'desc' ? 'DESC' : nil)
    column_name = model.column_names.collect { |c| model.table_name + '.' + c }.find { |c| c == params_column }
    column_name.blank? ? default_order : [column_name, direction].compact.join(' ')
  end

  private

  # TODO: Will be deprecated
  def set_viewable_project(id = :project_id)
    @project = current_user.all_viewable_and_site_projects.find_by_param(params[id])
  end

  # TODO: Will replace original set_viewable_project
  def find_viewable_project_or_redirect(id = :project_id)
    @project = current_user.all_viewable_and_site_projects.find_by_param(params[id])
    redirect_without_project
  end

  # TODO: Will be deprecated
  def set_editable_project(id = :project_id)
    @project = current_user.all_projects.find_by_param(params[id])
  end

  # TODO: Will replace original set_editable_project
  def find_editable_project_or_redirect(id = :project_id)
    @project = current_user.all_projects.find_by_param(params[id])
    redirect_without_project
  end

  def set_editable_project_or_editable_site
    @project = current_user.all_sheet_editable_projects.find_by_param(params[:project_id])
  end

  def redirect_without_project(path = root_path)
    empty_response_or_root_path(path) unless @project
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
    response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
  end

  def check_key_and_set_default_value(object, key, default_value)
    return unless params[object].key?(key) && params[object][key].blank?
    params[object][key] = default_value
  end

  def parse_date_if_key_present(object, key)
    return unless params[object].key?(key)
    params[object][key] = parse_date(params[object][key]) if params[object].key?(key)
  end
end
