# frozen_string_literal: true

# Helps convert report filters to sheet search filters.
module ReportsHelper
  def compute_filter_params(design, filters)
    filter_params = {}
    search = nil
    filters.each do |filter|
      search_parts = []
      variable = convert_variable_from_filter(filter)
      value = convert_value_from_filter(filter)
      if %(site_id).include?(variable)
        filter_params[variable.to_sym] = filter[:value]
      elsif value.present?
        search_parts << "#{variable}:#{value}"
      else
        search_parts << "#{variable}:>=#{filter[:start_date]}" if filter[:start_date].present?
        search_parts << "#{variable}:<=#{filter[:end_date]}" if filter[:end_date].present?
      end
      search = (search_parts + [search]).reject(&:blank?).join(' ')
    end
    filter_params[:search] = ""
    filter_params[:search] += "designs:#{design.to_param} " if design
    filter_params[:search] += search if search
    filter_params
  end

  def convert_variable_from_filter(filter)
    case filter[:variable].variable_type
    when 'sheet_date'
      'created'
    when 'site'
      'site_id'
    else
      filter[:variable].name
    end
  end

  def convert_value_from_filter(filter)
    if filter[:operator].present?
      filter[:operator]
    else
      filter[:value]
    end
  end
end
