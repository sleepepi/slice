# frozen_string_literal: true

module SheetExport
  extend ActiveSupport::Concern

  def generate_csv_sheets(sheet_scope, filename, raw_data, folder)
    sheet_scope = sheet_scope.order(id: :desc)
    tmp_export_file = File.join('tmp', 'files', 'exports', "#{filename}_#{raw_data ? 'raw' : 'labeled'}_tmp.csv")
    export_file = File.join('tmp', 'files', 'exports', "#{filename}_#{raw_data ? 'raw' : 'labeled'}.csv")

    t = Time.zone.now
    design_ids = sheet_scope.select(:design_id)
    variables = all_design_variables_using_design_ids(design_ids).where.not(variable_type: 'grid').includes(domain: :domain_options)

    CSV.open(tmp_export_file, 'wb') do |csv|
      csv << ['Subject'] + sheet_scope.joins(:subject).pluck(:subject_code)
      csv << ['Site'] + sheet_scope.includes(subject: :site).collect { |s| s.subject && s.subject.site ? s.subject.site.name : nil }
      csv << ['Event Name'] + sheet_scope.includes(subject_event: :event).collect { |s| s.subject_event && s.subject_event.event ? s.subject_event.event.name : nil }
      csv << ['Design Name'] + sheet_scope.joins(:design).pluck(:name)
      csv << ['Sheet ID'] + sheet_scope.pluck(:id)
      csv << ['Sheet Created'] + sheet_scope.pluck(:created_at).collect { |created| created.strftime('%F %T') }
      csv << ['Missing'] + sheet_scope.select(:missing).collect { |s| s.missing? ? 1 : 0 }

      variables.each do |v|
        if v.variable_type == 'checkbox'
          v.domain_options.each do |domain_option|
            sorted_responses = sort_responses_by_sheet_id_for_checkbox(v, sheet_scope, domain_option)
            formatted_responses = format_responses(v, raw_data, sorted_responses)
            csv << [v.option_variable_name(domain_option)] + formatted_responses
          end
        else
          sorted_responses = sort_responses_by_sheet_id_generic(v, sheet_scope)
          formatted_responses = format_responses(v, raw_data, sorted_responses)
          csv << [v.name] + formatted_responses
        end
        update_steps(1)
      end
    end
    transpose_tmp_csv(tmp_export_file, export_file)
    Rails.logger.debug "Total Time: #{Time.zone.now - t} seconds"
    ["#{folder}/#{export_file.split('/').last}", export_file]
  end

  def transpose_tmp_csv(tmp_export_file, export_file)
    arr_of_arrs = CSV.parse(File.open(tmp_export_file, 'r:iso-8859-1:utf-8', &:read))
    l = arr_of_arrs.map(&:length).max
    arr_of_arrs.map! { |e| e.values_at(0...l) }
    CSV.open(export_file, 'wb') do |csv|
      arr_of_arrs.transpose.each do |array|
        csv << array
      end
    end
  end

  def sort_responses_by_sheet_id_for_checkbox(variable, sheet_scope, domain_option)
    responses = Response.where(sheet_id: sheet_scope.select(:id), variable_id: variable.id, grid_id: nil)
                        .left_outer_joins(:domain_option)
                        .where(domain_options: { id: domain_option.id })
                        .order(sheet_id: :desc).distinct
                        .pluck('domain_options.value', :sheet_id)
    sort_responses_by_sheet_id(responses, sheet_scope)
  end

  def sort_responses_by_sheet_id_generic(variable, sheet_scope)
    # TODO: Change sheet_variables `response` to `value`
    response_scope = SheetVariable.where(sheet_id: sheet_scope.select(:id), variable_id: variable.id)
                                  .order(sheet_id: :desc)
    responses = if variable.variable_type == 'file'
                  response_scope.pluck(:response_file, :sheet_id).uniq
                else
                  response_scope
                    .left_outer_joins(:domain_option)
                    .pluck('domain_options.value', :value, :sheet_id)
                    .collect { |v1, v2, sheet_id| [v1 || v2, sheet_id] }.uniq
                end
    sort_responses_by_sheet_id(responses, sheet_scope)
  end

  def sort_responses_by_sheet_id(responses, sheet_scope)
    sorted_responses = Array.new(sheet_scope.count)
    response_counter = 0
    sheet_ids = sheet_scope.pluck(:id)
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
