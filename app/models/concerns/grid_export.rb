module GridExport
  extend ActiveSupport::Concern

  def generate_csv_grids(sheet_scope, filename, raw_data, folder)
    sheet_ids = sheet_scope.pluck(:id)
    sheet_scope = nil # Freeing Memory
    generate_csv_grids_internal(sheet_ids, filename, raw_data, folder)
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

    row = ["Sheet ID", "Name", "Description", "Sheet Creation Date", "Project", "Site", "Subject", "Acrostic", "Status", "Creator", "Schedule Name", "Event Name"]

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
      sheet = Sheet.find_by_id sheet_id
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
            sheet.subject_schedule ? sheet.subject_schedule.name : nil,
            sheet.event ? sheet.event.name : nil ]

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
            result = result.join(',') if result.kind_of?(Array)
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
    variable_ids = Design.where(id: design_ids).collect(&:variable_ids).flatten.uniq
    Variable.current.where(variable_type: 'grid', id: variable_ids)
  end
end
