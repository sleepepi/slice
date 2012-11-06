class ApplicationController < ActionController::Base
  protect_from_forgery

  layout "contour/layouts/application"

  def about

  end

  protected

  def check_system_admin
    redirect_to root_path, alert: "You do not have sufficient privileges to access that page." unless current_user.system_admin?
  end

  # Make sure to update sheet_variable.rb if this function is changed
  def parse_date(date_string, default_date = '')
    date_string.to_s.split('/').last.size == 2 ? Date.strptime(date_string, "%m/%d/%y") : Date.strptime(date_string, "%m/%d/%Y") rescue default_date
  end

  # Make sure to update sheet_variable.rb if this function is changed
  def parse_time(time_string, default_time = '')
    Time.parse(time_string).strftime('%H:%M:%S') rescue default_time
  end

  def scrub_order(model, params_order, default_order)
    (params_column, params_direction) = params_order.to_s.strip.downcase.split(' ')
    direction = (params_direction == 'desc' ? 'DESC' : nil)
    column_name = (model.column_names.collect{|c| model.table_name + "." + c}.select{|c| c == params_column}.first)
    order = column_name.blank? ? default_order : [column_name, direction].compact.join(' ')
    order
  end

  def latex_safe(mystring)
    symbols = [['\\', '\\textbackslash'], ['#', '\\#'], ['$', '\\$'], ['&', '\\&'], ['~', '\\~{}'], ['_', '\\_'], ['^', '\\^{}'], ['{', '\\{'], ['}', '\\}'], ['<', '\\textless{}'], ['>', '\\textgreater{}']]
    symbols.each do |from, to|
      mystring.gsub!(from, to)
    end
    mystring
  end

end
