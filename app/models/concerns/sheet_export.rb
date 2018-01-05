# frozen_string_literal: true

module SheetExport
  extend ActiveSupport::Concern

  def generate_csv_sheets(sheet_scope, filename, raw_data, folder)
    sheet_scope = sheet_scope.order(id: :desc)
    tmp_export_file = File.join("tmp", "files", "exports", "#{filename}_#{raw_data ? 'raw' : 'labeled'}_tmp.csv")
    export_file = File.join("tmp", "files", "exports", "#{filename}_#{raw_data ? 'raw' : 'labeled'}.csv")
    design_ids = sheet_scope.select(:design_id)
    variables = all_design_variables_using_design_ids(design_ids).where.not(variable_type: "grid").includes(domain: :domain_options)
    sheet_ids = sheet_scope.pluck(:id)
    CSV.open(tmp_export_file, "wb") do |csv|
      csv << ["Subject"] + sheet_scope.joins(:subject).pluck(:subject_code)
      csv << ["Site"] + sheet_scope.includes(subject: :site).collect { |s| s.subject && s.subject.site ? s.subject.site.export_value(raw_data) : nil }
      csv << ["Event"] + sheet_scope.includes(subject_event: :event).collect { |s| s.subject_event && s.subject_event.event ? s.subject_event.event.export_value(raw_data) : nil }
      csv << ["Design"] + sheet_scope.includes(:design).collect { |s| s.design ? s.design.export_value(raw_data) : nil }
      csv << ["Sheet ID"] + sheet_ids
      csv << ["Sheet Coverage"] + sheet_scope.pluck(:percent)
      csv << ["Sheet Created"] + sheet_scope.pluck(:created_at).collect { |created| created.strftime("%F %T") }
      csv << ["Missing"] + sheet_scope.select(:missing).collect { |s| s.missing? ? 1 : 0 }
      load_all(variables, sheet_ids, raw_data, csv)
    end
    transpose_tmp_csv(tmp_export_file, export_file)
    ["#{folder}/#{export_file.split('/').last}", export_file]
  end

  def load_all(variables, sheet_ids, raw_data, csv)
    check_stuff = load_all_checkboxes(variables, sheet_ids)
    file_stuff = load_all_files(variables, sheet_ids)
    other_stuff = load_all_other_variables(variables, sheet_ids)
    variables.uniq.each do |v|
      if v.variable_type == "checkbox"
        v.domain_options.each do |domain_option|
          key = "#{v.id}:#{domain_option.id}"
          responses = pull_checkbox_responses(check_stuff, key)
          sorted_responses = sort_responses_by_sheet_id(responses, sheet_ids)
          formatted_responses = format_responses(v, raw_data, sorted_responses)
          csv << [v.option_variable_name(domain_option)] + formatted_responses
        end
      else
        key = v.id.to_s
        responses = \
          if %w(file signature).include?(v.variable_type)
            pull_responses(file_stuff, key)
          else
            pull_responses(other_stuff, key)
          end
        file_stuff[key] = nil
        other_stuff[key] = nil
        sorted_responses = sort_responses_by_sheet_id(responses, sheet_ids)
        formatted_responses = format_responses(v, raw_data, sorted_responses)
        csv << [v.name] + formatted_responses
      end
      update_steps(1)
    end
  end

  def pull_responses(hash, key)
    if hash[key].nil?
      []
    else
      hash[key].collect { |_, val, sheet_id| [val, sheet_id] }
    end
  end

  def pull_checkbox_responses(hash, key)
    if hash[key].nil?
      []
    else
      hash[key].collect { |_, _, val, sheet_id| [val, sheet_id] }
    end
  end

  def load_all_checkboxes(variables, sheet_ids)
    filtered_variables = variables.where(variable_type: "checkbox")
    Response
      .where(sheet_id: sheet_ids, variable: filtered_variables, grid_id: nil)
      .order(sheet_id: :desc)
      .left_outer_joins(:domain_option)
      .distinct
      .pluck(:variable_id, "domain_options.id", "domain_options.value", :sheet_id).uniq
      .group_by { |variable_id, domain_option_id, _, _| "#{variable_id}:#{domain_option_id}" }
  end

  def load_all_files(variables, sheet_ids)
    filtered_variables = variables.where(variable_type: %w(file signature))
    SheetVariable
      .where(sheet_id: sheet_ids, variable: filtered_variables)
      .order(sheet_id: :desc)
      .pluck(:variable_id, :response_file, :sheet_id).uniq
      .group_by { |variable_id, _, _| variable_id.to_s }
  end

  def load_all_other_variables(variables, sheet_ids)
    filtered_variables = variables.where.not(variable_type: %w(checkbox file signature))
    SheetVariable
      .where(sheet_id: sheet_ids, variable: filtered_variables)
      .order(sheet_id: :desc)
      .left_outer_joins(:domain_option)
      .pluck(:variable_id, domain_option_value_or_value, :sheet_id).uniq
      .group_by { |variable_id, _, _| variable_id.to_s }
  end

  def domain_option_value_or_value(table: "sheet_variables")
    Arel.sql("(CASE WHEN (NULLIF(domain_options.value, '') IS NULL) "\
    "THEN NULLIF(#{table}.value, '') ELSE NULLIF(domain_options.value, '') END)")
  end

  def transpose_tmp_csv(tmp_export_file, export_file)
    arr_of_arrs = CSV.parse(File.open(tmp_export_file, "r:iso-8859-1:utf-8", &:read))
    l = arr_of_arrs.map(&:length).max
    arr_of_arrs.map! { |e| e.values_at(0...l) }
    CSV.open(export_file, "wb") do |csv|
      arr_of_arrs.transpose.each do |array|
        csv << array
      end
    end
  end

  def sort_responses_by_sheet_id(responses, sheet_ids)
    sorted_responses = Array.new(sheet_ids.size)
    response_counter = 0
    sheet_ids.each_with_index do |sheet_id, index|
      current_response_and_sheet_id = responses[response_counter]
      if current_response_and_sheet_id && current_response_and_sheet_id.last == sheet_id
        sorted_responses[index] = current_response_and_sheet_id.first
        response_counter += 1
      end
    end
    sorted_responses
  end

  def format_responses(variable, raw_data, responses)
    formatter = Formatters.for(variable)
    formatter.format_array(responses, raw_data)
  end
end
