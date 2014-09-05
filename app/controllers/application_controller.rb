class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # layout "contour/layouts/application"
  layout "layouts/application_custom"

  include DateAndTimeParser

  def theme
    render layout: 'theme'
  end

  def font
    render layout: 'theme'
  end

  protected

  def check_system_admin
    redirect_to root_path, alert: "You do not have sufficient privileges to access that page." unless current_user.system_admin?
  end

  def scrub_order(model, params_order, default_order)
    (params_column, params_direction) = params_order.to_s.strip.downcase.split(' ')
    direction = (params_direction == 'desc' ? 'DESC' : nil)
    column_name = (model.column_names.collect{|c| model.table_name + "." + c}.select{|c| c == params_column}.first)
    order = column_name.blank? ? default_order : [column_name, direction].compact.join(' ')
    order
  end

  private

  def set_viewable_project(id = :project_id)
    @project = current_user.all_viewable_and_site_projects.find_by_id(params[id])
  end

  def set_editable_project(id = :project_id)
    @project = current_user.all_projects.find_by_id(params[id])
  end

  def set_editable_project_or_editable_site
    @project = current_user.all_sheet_editable_projects.find_by_id(params[:project_id])
  end

  def redirect_without_project(path = root_path)
    empty_response_or_root_path(path) unless @project
  end

  def empty_response_or_root_path(path = root_path)
    respond_to do |format|
      format.html { redirect_to path }
      format.js { render nothing: true }
      format.json { head :no_content }
    end
  end

end
