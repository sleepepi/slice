# frozen_string_literal: true

module GridExport
  extend ActiveSupport::Concern

  def generate_csv_grids_orig(sheet_scope, filename, raw_data, folder)
    sheet_ids = sheet_scope.pluck(:id)
    sheet_scope = nil # Freeing Memory
    generate_csv_grids_internal(sheet_ids, filename, raw_data, folder)
  end

  def generate_csv_grids(sheet_scope, filename, raw_data, folder)
    sheet_scope = sheet_scope.order(id: :desc)
    tmp_export_file = File.join('tmp', 'files', 'exports', "#{filename}_grids__#{raw_data ? 'raw' : 'labeled'}_tmp.csv")
    export_file = File.join('tmp', 'files', 'exports', "#{filename}_grids__#{raw_data ? 'raw' : 'labeled'}.csv")

    t = Time.now
    select_design_ids = sheet_scope.select(:design_id)
    grid_group_variables = all_design_variables_only_grids_using_design_ids(select_design_ids)

    sheet_ids = compute_sheet_ids_with_max_position(sheet_scope)

    CSV.open(tmp_export_file, 'wb') do |csv|
      csv << ['', 'Sheet ID'] + sheet_ids
      csv << ['', 'Name'] + grid_get_corresponding_names(sheet_ids, sheet_scope.joins(:design).pluck(:id, :name))
      csv << ['', 'Description'] + grid_get_corresponding_names(sheet_ids, sheet_scope.joins(:design).pluck(:id, :description))
      csv << ['', 'Sheet Creation Date'] + grid_get_corresponding_names(sheet_ids, sheet_scope.pluck(:id, :created_at).collect{ |id, s| [id, s.strftime('%Y-%m-%d')]})
      csv << ['', 'Project'] + grid_get_corresponding_names(sheet_ids, sheet_scope.joins(:project).pluck(:id, :name))
      csv << ['', 'Site'] + grid_get_corresponding_names(sheet_ids, sheet_scope.includes(subject: :site).collect { |s| [s.id, s.subject && s.subject.site ? s.subject.site.name : nil] })
      csv << ['', 'Subject'] + grid_get_corresponding_names(sheet_ids, sheet_scope.joins(:subject).pluck(:id, :subject_code))
      csv << ['', 'Acrostic'] + grid_get_corresponding_names(sheet_ids, sheet_scope.joins(:subject).pluck(:id, :acrostic))
      csv << ['', 'Status'] + grid_get_corresponding_names(sheet_ids, sheet_scope.joins(:subject).pluck(:id, :status))
      csv << ['', 'Creator'] + grid_get_corresponding_names(sheet_ids, sheet_scope.includes(:user).collect { |s| [s.id, s.user ? "#{s.user.first_name} #{s.user.last_name}" : nil] })
      csv << ['', 'Event Name'] + grid_get_corresponding_names(sheet_ids, sheet_scope.includes(subject_event: :event).collect { |s| [s.id, s.subject_event && s.subject_event.event ? s.subject_event.event.name : nil] })

      grid_group_variables.each do |grid_group_variable|
        grid_variables = grid_group_variable.project.variables.where(id: grid_group_variable.grid_variables.collect { |gv| gv[:variable_id] }).to_a
        grid_group_variable.grid_variables.each do |grid_variable_hash|
          v = grid_variables.find { |gv| gv.id == grid_variable_hash[:variable_id].to_i }
          next unless v
          if v.variable_type == 'checkbox'
            v.shared_options.each do |option|
              value = option[:value]
              sorted_responses = grid_sort_responses_by_sheet_id_for_checkbox(grid_group_variable, v, sheet_scope, sheet_ids, value)
              formatted_responses = format_responses(v, raw_data, sorted_responses)
              csv << [grid_group_variable.name, "#{v.name}__#{value}"] + formatted_responses
            end
          else
            sorted_responses = grid_sort_responses_by_sheet_id_generic(grid_group_variable, v, sheet_scope, sheet_ids)
            formatted_responses = format_responses(v, raw_data, sorted_responses)
            csv << [grid_group_variable.name, v.name] + formatted_responses
          end
          update_steps(1) unless new_record? # TODO: Remove unless conditional
        end
      end
    end
    transpose_tmp_csv(tmp_export_file, export_file)
    Rails.logger.debug "Total Time: #{Time.now - t} seconds"
    ["#{folder.upcase}/#{export_file.split('/').last}", export_file]
  end

  def grid_get_corresponding_names(sheet_ids, ids_and_names)
    sheet_ids.collect do |sheet_id|
      ids_and_names.find { |v| v.first == sheet_id }.last
    end
  end

  def grid_sort_responses_by_sheet_id_for_checkbox(grid_group_variable, variable, sheet_scope, sheet_ids, value)
    responses = Response.where(sheet_id: sheet_scope.select(:id), variable_id: variable.id, value: value)
                        .where.not(grid_id: nil)
                        .order(sheet_id: :desc).pluck(:value, :sheet_id, :grid_id).uniq
    grid_sort_responses_by_sheet_id(grid_group_variable, responses, sheet_scope)
  end

  def grid_sort_responses_by_sheet_id_generic(grid_group_variable, variable, sheet_scope, sheet_ids)
    responses = Grid.joins(:sheet_variable).merge(SheetVariable.where(sheet_id: sheet_scope.select(:id)))
                    .where(variable_id: variable.id)
                    .order('sheet_id desc', :position)
                    .pluck(:response, :position, :sheet_id).uniq
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

  private

  def generate_csv_grids_internal(sheet_ids, filename, raw_data, folder)
    export_file = File.join('tmp', 'files', 'exports', "#{filename}_grids_#{raw_data ? 'raw' : 'labeled'}.csv")

    CSV.open(export_file, "wb") do |csv|
      grid_group_variables = all_design_variables_only_grids_using_design_ids(Sheet.where(id: sheet_ids).pluck(:design_id).uniq)

      write_grid_csv_header(csv, grid_group_variables)
      write_grid_csv_body(sheet_ids, csv, raw_data, grid_group_variables)

      grid_group_variables = nil # Freeing Memory
    end

    ["#{folder.upcase}/#{export_file.split('/').last}", export_file]
  end

  def write_grid_csv_header(csv, grid_group_variables)
    row = ["", "", "", "", "", "", "", "", "", "", "", ""]

    all_grid_variables = Variable.current.where(id: grid_group_variables.collect{|v| v.grid_variables.collect{|gv| gv[:variable_id]}}.flatten).to_a

    grid_group_variables.each do |variable|
      variable.grid_variables.each do |grid_variable|
        v = all_grid_variables.select{|gv| gv.id == grid_variable[:variable_id].to_i}.first
        row << variable.name if v
        v = nil # Freeing Memory
      end
    end

    csv << row

    row = ["Sheet ID", "Name", "Description", "Sheet Creation Date", "Project", "Site", "Subject", "Acrostic", "Status", "Creator", "Event Name"]

    grid_group_variables.each do |variable|
      variable.grid_variables.each do |grid_variable|
        v = all_grid_variables.select{|gv| gv.id == grid_variable[:variable_id].to_i}.first
        row << v.name if v
        v = nil # Freeing Memory
      end
    end

    csv << row
  end

  def write_grid_csv_body(sheet_ids, csv, raw_data, grid_group_variables)
    sheet_ids.sort.reverse.each do |sheet_id|
      sheet = Sheet.includes(:project, :user, :subject_event, subject: [:site]).find_by_id sheet_id
      write_grid_sheet_to_csv(csv, sheet, grid_group_variables, raw_data) if sheet
      sheet = nil # Freeing Memory
      update_steps(1)
    end
  end

  def write_grid_sheet_to_csv(csv, sheet, grid_group_variables, raw_data)
    row = [ sheet.id,
            sheet.name,
            sheet.description,
            sheet.created_at.strftime("%Y-%m-%d"),
            sheet.project.name,
            sheet.subject.site.name,
            sheet.subject.name,
            sheet.project.acrostic_enabled? ? sheet.subject.acrostic : nil,
            sheet.subject.status,
            sheet.user ? sheet.user.name : nil,
            sheet.subject_event ? sheet.subject_event.name : nil ]

    position = 1

    sheet_variables = sheet.sheet_variables.includes(grids: [variable: [:domain]]).to_a

    (0..sheet.max_grids_position).to_a.each do |position|
      grid_row = []
      grid_group_variables.each do |variable|
        sheet_variable = sheet_variables.select{ |sv| sv.variable_id == variable.id }.first
        all_grids = sheet_variable.grids.to_a if sheet_variable
        variable.grid_variables.each do |grid_variable|
          if sheet_variable and all_grids and grid = all_grids.select{|g| g.variable_id == grid_variable[:variable_id].to_i and g.position == position}.first
            result = (raw_data ? grid.get_response(:raw) : grid.get_response(:name))
            result = result.join(',') if result.is_a?(Array)
          else
            result = nil
          end
          grid_row << result
        end
        sheet_variable = nil # Freeing Memory
      end
      csv << (row + grid_row) unless grid_row.compact.empty?
      grid_row = nil
    end
    row = nil # Freeing Memory
  end

  def all_design_variables_only_grids_using_design_ids(design_ids)
    Variable.current.joins(:design_options)
            .where(design_options: { design_id: design_ids })
            .where(variable_type: 'grid')
            .order('design_options.design_id', 'design_options.position')
  end
end
