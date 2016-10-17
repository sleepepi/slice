# frozen_string_literal: true

# Helps convert report filters to sheet search filters.
module ReportsHelper
  def compute_filter_params(project, design, filters)
    filter_params = {}
    search = nil
    filters.each do |filter|
      search_parts = []
      variable = convert_variable_from_filter(project, filter)
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
    filter_params[:design_id] = design.id if design
    filter_params[:search] = search
    filter_params
  end

  def convert_variable_from_filter(project, filter)
    case filter[:variable_id]
    when 'sheet_date'
      'created'
    when 'site'
      'site_id'
    else
      v = project.variables.find_by id: filter[:variable_id]
      if v
        v.name
      else
        filter[:variable_id].to_s
      end
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
