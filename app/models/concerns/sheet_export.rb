# frozen_string_literal: true

module SheetExport
  extend ActiveSupport::Concern

  def generate_csv_sheets(sheet_scope, filename, raw_data, folder)
    sheet_scope = sheet_scope.order(id: :desc)
    tmp_export_file = File.join('tmp', 'files', 'exports', "#{filename}_#{raw_data ? 'raw' : 'labeled'}_tmp.csv")
    export_file = File.join('tmp', 'files', 'exports', "#{filename}_#{raw_data ? 'raw' : 'labeled'}.csv")

    t = Time.zone.now
    design_ids = sheet_scope.select(:design_id)
    variables = all_design_variables_using_design_ids(design_ids).where.not(variable_type: 'grid').includes(:domain)

    sheet_ids = sheet_scope.pluck(:id)

    CSV.open(tmp_export_file, 'wb') do |csv|
      csv << ['Sheet ID'] + sheet_ids
      csv << ['Name'] + sheet_scope.joins(:design).pluck(:name)
      csv << ['Description'] + sheet_scope.joins(:design).pluck(:description)
      csv << ['Sheet Creation Date'] + sheet_scope.pluck(:created_at).collect { |s| s.strftime('%Y-%m-%d') }
      csv << ['Project'] + sheet_scope.joins(:project).pluck(:name)
      csv << ['Site'] + sheet_scope.includes(subject: :site).collect { |s| s.subject && s.subject.site ? s.subject.site.name : nil }
      csv << ['Subject'] + sheet_scope.joins(:subject).pluck(:subject_code)
      csv << ['Acrostic'] + sheet_scope.joins(:subject).pluck(:acrostic)
      csv << ['Creator'] + sheet_scope.includes(:user).collect { |s| s.user ? "#{s.user.first_name} #{s.user.last_name}" : nil }
      csv << ['Event Name'] + sheet_scope.includes(subject_event: :event).collect { |s| s.subject_event && s.subject_event.event ? s.subject_event.event.name : nil }

      variables.each do |v|
        if v.variable_type == 'checkbox'
          v.shared_options.each do |option|
            value = option[:value]
            sorted_responses = sort_responses_by_sheet_id_for_checkbox(v, sheet_scope, value)
            formatted_responses = format_responses(v, raw_data, sorted_responses)
            csv << ["#{v.name}__#{value}"] + formatted_responses
          end
        else
          sorted_responses = sort_responses_by_sheet_id_generic(v, sheet_scope)
          formatted_responses = format_responses(v, raw_data, sorted_responses)
          csv << [v.name] + formatted_responses
        end
        update_steps(1) unless new_record? # TODO: Remove unless conditional
      end
    end
    transpose_tmp_csv(tmp_export_file, export_file)
    Rails.logger.debug "Total Time: #{Time.zone.now - t} seconds"
    ["#{folder.upcase}/#{export_file.split('/').last}", export_file]
  end

  def transpose_tmp_csv(tmp_export_file, export_file)
    arr_of_arrs = CSV.parse(File.open(tmp_export_file, 'r:iso-8859-1:utf-8') { |f| f.read })
    l = arr_of_arrs.map(&:length).max
    arr_of_arrs.map! { |e| e.values_at(0...l) }
    CSV.open(export_file, 'wb') do |csv|
      arr_of_arrs.transpose.each do |array|
        csv << array
      end
    end
  end

  def sort_responses_by_sheet_id_for_checkbox(variable, sheet_scope, value)
    responses = Response.where(sheet_id: sheet_scope.select(:id), variable_id: variable.id, value: value, grid_id: nil)
                        .order(sheet_id: :desc).pluck(:value, :sheet_id).uniq
    sort_responses_by_sheet_id(responses, sheet_scope)
  end

  def sort_responses_by_sheet_id_generic(variable, sheet_scope)
    responses = SheetVariable.where(sheet_id: sheet_scope.select(:id), variable_id: variable.id)
                             .order(sheet_id: :desc).pluck(:response, :sheet_id).uniq
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
    formatted_responses = case variable.variable_type
                          when 'integer'
                            Formatters::IntegerFormatter.format_array(responses, variable, raw_data)
                          when 'numeric', 'calculated'
                            Formatters::NumericFormatter.format_array(responses, variable, raw_data)
                          when 'dropdown', 'radio', 'checkbox'
                            Formatters::DomainFormatter.format_array(responses, variable, raw_data)
                          when 'date'
                            Formatters::DateFormatter.format_array(responses, variable, raw_data)
                          when 'time'
                            Formatters::TimeFormatter.format_array(responses, variable, raw_data)
                          when 'time_duration'
                            Formatters::TimeDurationFormatter.format_array(responses, variable, raw_data)
                          # when 'file'
                          #   responses
                          else # 'string', 'text', 'signature'
                            Formatters::DefaultFormatter.format_array(responses, variable, raw_data)
                          end

    formatted_responses
  end
end
