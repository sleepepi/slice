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

  def check_date
    month = parse_integer(params[:month])
    day = parse_integer(params[:day])
    year = parse_integer(params[:year])
    @date = parse_date("#{month}/#{day}/#{year}")
    @message = ''

    if @date.class == Date
      if @date.year > Date.today.year
        @status = 'warning'
        @message = 'Far out date! Are you from the future?'
      elsif @date.year < Date.today.year - 50
        @status = 'warning'
        @message = 'Ancient digs! Did you enter the correct year?'
      else
        @status = 'success'
      end
    elsif month.blank? && day.blank? && year.blank?
      @status = 'empty'
    else
      @status = 'error'
    end
  end

  protected

  def check_system_admin
    redirect_to root_path, alert: 'You do not have sufficient privileges to access that page.' unless current_user.system_admin?
  end

  def scrub_order(model, params_order, default_order)
    (params_column, params_direction) = params_order.to_s.strip.downcase.split(' ')
    direction = (params_direction == 'desc' ? 'DESC' : nil)
    column_name = (model.column_names.collect { |c| model.table_name + '.' + c }.select { |c| c == params_column }.first)
    order = column_name.blank? ? default_order : [column_name, direction].compact.join(' ')
    order
  end

  private

  def set_viewable_project(id = :project_id)
    @project = current_user.all_viewable_and_site_projects.find_by_param(params[id])
  end

  def set_editable_project(id = :project_id)
    @project = current_user.all_projects.find_by_param(params[id])
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
end
