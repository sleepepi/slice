# frozen_string_literal: true

module GridExport
  extend ActiveSupport::Concern

  def generate_csv_grids(sheet_scope, temp_dir, filename, raw_data, folder)
    sheet_scope = sheet_scope.order(id: :desc)
    tmp_export_file = File.join(temp_dir, "#{filename}_grids_#{raw_data ? "raw" : "labeled"}_tmp.csv")
    export_file = File.join(temp_dir, "#{filename}_grids_#{raw_data ? "raw" : "labeled"}.csv")
    design_ids = sheet_scope.select(:design_id)
    grid_group_variables = all_design_variables_using_design_ids(design_ids).where(variable_type: "grid")
    sheet_ids = compute_sheet_ids_with_max_position(sheet_scope)
    CSV.open(tmp_export_file, "wb") do |csv|
      csv << ["", "Subject"] + grid_get_corresponding_names(sheet_ids, sheet_scope.joins(:subject).pluck(:id, :subject_code))
      csv << ["", "Site"] + grid_get_corresponding_names(sheet_ids, sheet_scope.includes(subject: :site).collect { |s| [s.id, s.subject && s.subject.site ? s.subject.site.export_value(raw_data) : nil] })
      csv << ["", "Event"] + grid_get_corresponding_names(sheet_ids, sheet_scope.includes(subject_event: :event).collect { |s| [s.id, s.subject_event && s.subject_event.event ? s.subject_event.event.export_value(raw_data) : nil] })
      csv << ["", "Design"] + grid_get_corresponding_names(sheet_ids, sheet_scope.includes(:design).collect { |s| [s.id, s.design ? s.design.export_value(raw_data) : nil] })
      csv << ["", "Sheet ID"] + sheet_ids
      load_all_grids(grid_group_variables, sheet_ids, raw_data, csv)
    end
    transpose_tmp_csv(tmp_export_file, export_file)
    ["#{folder}/#{export_file.split("/").last}", export_file]
  end

  def grid_get_corresponding_names(sheet_ids, ids_and_names)
    sheet_ids.collect do |sheet_id|
      ids_and_names.find { |v| v.first == sheet_id }.last
    end
  end

  def load_all_grids(grid_group_variables, sheet_ids, raw_data, csv)
    check_stuff = load_all_grid_checkboxes(grid_group_variables, sheet_ids)
    file_stuff = load_all_grid_files(grid_group_variables, sheet_ids)
    other_stuff = load_all_grid_other_variables(grid_group_variables, sheet_ids)
    grid_group_variables.uniq.each do |grid_group_variable|
      grid_group_variable.child_variables.includes(domain: :domain_options).each do |child_variable|
        if child_variable.variable_type == "checkbox"
          child_variable.domain_options.each do |domain_option|
            key = "#{grid_group_variable.id}:#{child_variable.id}:#{domain_option.id}"
            responses = pull_grid_checkbox_responses(check_stuff, key)
            sorted_responses = grid_sort_responses_by_sheet_id(responses, sheet_ids)
            formatted_responses = format_responses(child_variable, raw_data, sorted_responses)
            csv << [grid_group_variable.name, child_variable.option_variable_name(domain_option)] + formatted_responses
          end
        else
          key = "#{grid_group_variable.id}:#{child_variable.id}"
          responses = \
            if %w(file signature).include?(child_variable.variable_type)
              pull_grid_responses(file_stuff, key)
            else
              pull_grid_responses(other_stuff, key)
            end
          file_stuff[key] = nil
          other_stuff[key] = nil
          sorted_responses = grid_sort_responses_by_sheet_id(responses, sheet_ids)
          formatted_responses = format_responses(child_variable, raw_data, sorted_responses)
          csv << [grid_group_variable.name, child_variable.name] + formatted_responses
        end
      end
      update_steps(1)
    end
  end

  def pull_grid_responses(hash, key)
    if hash[key].nil?
      []
    else
      hash[key].collect { |_, _, value, position, sheet_id| [value, position, sheet_id] }
    end
  end

  def pull_grid_checkbox_responses(hash, key)
    if hash[key].nil?
      []
    else
      hash[key].collect { |_, _, _, value, position, sheet_id| [value, position, sheet_id] }
    end
  end

  def load_all_grid_checkboxes(grid_group_variables, sheet_ids)
    Response
      .joins(:variable, grid: :sheet_variable)
      .where(variables: { variable_type: "checkbox" })
      .where(sheet_variables: { sheet_id: sheet_ids.uniq, variable: grid_group_variables })
      .where(sheet_id: sheet_ids.uniq)
      .order("sheet_id desc", "grids.position")
      .left_outer_joins(:domain_option)
      .distinct
      .pluck("sheet_variables.variable_id", :variable_id, "domain_options.id", "domain_options.value", "grids.position", :sheet_id).uniq
      .group_by { |group_variable_id, variable_id, domain_option_id, _, _, _| "#{group_variable_id}:#{variable_id}:#{domain_option_id}" }
  end

  def load_all_grid_files(grid_group_variables, sheet_ids)
    Grid
      .joins(:variable, :sheet_variable)
      .where(variables: { variable_type: %w(file signature) })
      .where(sheet_variables: { sheet_id: sheet_ids.uniq, variable: grid_group_variables })
      .order("sheet_id desc", :position)
      .pluck("sheet_variables.variable_id", :variable_id, :response_file, :position, :sheet_id).uniq
      .group_by { |group_variable_id, variable_id, _, _, _| "#{group_variable_id}:#{variable_id}" }
  end

  def load_all_grid_other_variables(grid_group_variables, sheet_ids)
    Grid
      .joins(:variable, :sheet_variable)
      .where.not(variables: { variable_type: %w(checkbox file signature) })
      .where(sheet_variables: { sheet_id: sheet_ids.uniq, variable: grid_group_variables })
      .order("sheet_id desc", :position)
      .left_outer_joins(:domain_option)
      .pluck(
        "sheet_variables.variable_id",
        :variable_id,
        domain_option_value_or_value(table: "grids"),
        :position,
        :sheet_id
      ).uniq
      .group_by { |group_variable_id, variable_id, _, _, _| "#{group_variable_id}:#{variable_id}" }
  end

  def grid_sort_responses_by_sheet_id(responses, sheet_ids)
    sorted_responses = Array.new(sheet_ids.size)
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
    all_positions = Grid.joins(:sheet_variable)
                        .merge(SheetVariable.where(sheet_id: sheet_scope.select(:id)))
                        .pluck(:sheet_id, :position)
    all_positions.each do |sheet_id, position|
      highest_hash[sheet_id.to_s] ||= 0
      highest_hash[sheet_id.to_s] = position if position > highest_hash[sheet_id.to_s]
    end
    highest_hash.collect { |sheet_id, position| [sheet_id.to_i] * (position + 1) }.flatten.sort.reverse
  end
end
