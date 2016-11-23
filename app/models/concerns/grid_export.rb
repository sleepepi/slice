# frozen_string_literal: true

module GridExport
  extend ActiveSupport::Concern

  def generate_csv_grids(sheet_scope, filename, raw_data, folder)
    sheet_scope = sheet_scope.order(id: :desc)
    tmp_export_file = File.join('tmp', 'files', 'exports', "#{filename}_grids_#{raw_data ? 'raw' : 'labeled'}_tmp.csv")
    export_file = File.join('tmp', 'files', 'exports', "#{filename}_grids_#{raw_data ? 'raw' : 'labeled'}.csv")

    t = Time.zone.now
    design_ids = sheet_scope.select(:design_id)
    grid_group_variables = all_design_variables_using_design_ids(design_ids).where(variable_type: 'grid')

    sheet_ids = compute_sheet_ids_with_max_position(sheet_scope)

    CSV.open(tmp_export_file, 'wb') do |csv|
      csv << ['', 'Subject'] + grid_get_corresponding_names(sheet_ids, sheet_scope.joins(:subject).pluck(:id, :subject_code))
      csv << ['', 'Site'] + grid_get_corresponding_names(sheet_ids, sheet_scope.includes(subject: :site).collect { |s| [s.id, s.subject && s.subject.site ? s.subject.site.name : nil] })
      csv << ['', 'Event Name'] + grid_get_corresponding_names(sheet_ids, sheet_scope.includes(subject_event: :event).collect { |s| [s.id, s.subject_event && s.subject_event.event ? s.subject_event.event.name : nil] })
      csv << ['', 'Design Name'] + grid_get_corresponding_names(sheet_ids, sheet_scope.joins(:design).pluck(:id, :name))
      csv << ['', 'Sheet ID'] + sheet_ids

      grid_group_variables.each do |grid_group_variable|
        grid_group_variable.child_variables.includes(domain: :domain_options).each do |child_variable|
          if child_variable.variable_type == 'checkbox'
            child_variable.domain_options.each do |domain_option|
              sorted_responses = grid_sort_responses_by_sheet_id_for_checkbox(grid_group_variable, child_variable, sheet_scope, sheet_ids, domain_option)
              formatted_responses = format_responses(child_variable, raw_data, sorted_responses)
              csv << [grid_group_variable.name, child_variable.option_variable_name(domain_option)] + formatted_responses
            end
          else
            sorted_responses = grid_sort_responses_by_sheet_id_generic(grid_group_variable, child_variable, sheet_scope, sheet_ids)
            formatted_responses = format_responses(child_variable, raw_data, sorted_responses)
            csv << [grid_group_variable.name, child_variable.name] + formatted_responses
          end
        end
        update_steps(1)
      end
    end
    transpose_tmp_csv(tmp_export_file, export_file)
    Rails.logger.debug "Total Time: #{Time.zone.now - t} seconds"
    ["#{folder.upcase}/#{export_file.split('/').last}", export_file]
  end

  def grid_get_corresponding_names(sheet_ids, ids_and_names)
    sheet_ids.collect do |sheet_id|
      ids_and_names.find { |v| v.first == sheet_id }.last
    end
  end

  def grid_sort_responses_by_sheet_id_for_checkbox(grid_group_variable, variable, sheet_scope, sheet_ids, domain_option)
    responses = Response.joins(:grid)
                        .where(sheet_id: sheet_scope.select(:id), variable_id: variable.id)
                        .where.not(grid_id: nil)
                        .left_outer_joins(:domain_option)
                        .where(domain_options: { id: domain_option.id })
                        .order('sheet_id desc', 'grids.position').distinct
                        .pluck('domain_options.value', 'grids.position', :sheet_id)
    grid_sort_responses_by_sheet_id(grid_group_variable, responses, sheet_scope, sheet_ids)
  end

  def grid_sort_responses_by_sheet_id_generic(grid_group_variable, variable, sheet_scope, sheet_ids)
    response_scope = Grid.joins(:sheet_variable).merge(SheetVariable.where(sheet_id: sheet_scope.select(:id)))
                         .where(variable_id: variable.id)
                         .order('sheet_id desc', :position)
    responses = if variable.variable_type == 'file'
                  response_scope.pluck(:response_file, :position, :sheet_id).uniq
                else
                  response_scope
                    .left_outer_joins(:domain_option)
                    .pluck('domain_options.value', :response, :position, :sheet_id)
                    .collect { |v1, v2, position, sheet_id| [v1 || v2, position, sheet_id] }.uniq
                end
    grid_sort_responses_by_sheet_id(grid_group_variable, responses, sheet_scope, sheet_ids)
  end

  def grid_sort_responses_by_sheet_id(grid_group_variable, responses, sheet_scope, sheet_ids)
    sorted_responses = Array.new(sheet_ids.count)
    response_counter = 0
    current_sheet_position = nil
    last_sheet_id = nil
    sheet_ids.each_with_index do |sheet_id, index|
      if sheet_id == last_sheet_id
        current_sheet_position += 1
      else
        current_sheet_position = 0
      end
      response = responses[response_counter]
      if response && response[1] == current_sheet_position && response.last == sheet_id
        sorted_responses[index] = response.first
        response_counter += 1
      end
      last_sheet_id = sheet_id
    end
    sorted_responses
  end

  # Computes how many maximum grid rows per sheet need to be exported and
  # returns the sheet_ids in descending order
  def compute_sheet_ids_with_max_position(sheet_scope)
    highest_hash = {}
    all_positions = Grid.joins(:sheet_variable).merge(SheetVariable.where(sheet_id: sheet_scope.select(:id))).pluck(:sheet_id, :position)
    all_positions.each do |sheet_id, position|
      highest_hash[sheet_id.to_s] ||= 0
      highest_hash[sheet_id.to_s] = position if position > highest_hash[sheet_id.to_s]
    end
    highest_hash.collect { |sheet_id, position| [sheet_id.to_i] * (position + 1) }.flatten.sort.reverse
  end
end
