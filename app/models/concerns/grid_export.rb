module GridExport
  extend ActiveSupport::Concern

  def generate_csv_grids(sheet_scope, filename, raw_data, folder)
    generate_csv_grids_internal(sheet_scope, filename, raw_data, folder)
  end

  private

  def generate_csv_grids_internal(sheet_scope, filename, raw_data, folder)
    export_file = File.join('tmp', 'files', 'exports', "#{filename}_grids_#{raw_data ? 'raw' : 'labeled'}.csv")

    rows = []

    sheet_scope.each do |sheet|
      hash = { sheet_id: sheet.id, rows: [] }
      sheet.sheet_variables.each do |sv|
        if sv.variable.variable_type == 'grid'
          sv.grids.each do |grid|
            hash[:rows][grid.position] ||= {}
            hash[:rows][grid.position][sv.variable_id.to_s] ||= {}

            result = (raw_data ? grid.get_response(:raw) : grid.get_response(:name))
            result = result.join(',') if result.kind_of?(Array)

            hash[:rows][grid.position][sv.variable_id.to_s][grid.variable_id.to_s] = result
          end
        end
      end
      rows << hash
      update_steps(1)
    end

    CSV.open(export_file, "wb") do |csv|
      variable_ids = Design.where(id: sheet_scope.pluck(:design_id)).collect(&:variable_ids).flatten.uniq
      grid_group_variables = Variable.current.where(variable_type: 'grid', id: variable_ids)

      row = ["", "", "", "", "", "", "", "", "", "", "", ""]

      grid_group_variables.each do |variable|
        variable.grid_variables.each do |grid_variable_hash|
          grid_variable = Variable.current.find_by_id(grid_variable_hash[:variable_id])
          row << variable.name if grid_variable
        end
      end

      csv << row

      row = ["Sheet ID", "Name", "Description", "Sheet Creation Date", "Project", "Site", "Subject", "Acrostic", "Status", "Creator", "Schedule Name", "Event Name"]

      grid_group_variables.each do |variable|
        variable.grid_variables.each do |grid_variable_hash|
          grid_variable = Variable.current.find_by_id(grid_variable_hash[:variable_id])
          row << grid_variable.name if grid_variable
        end
      end

      csv << row

      rows.each do |hash|
        sheet = sheet_scope.find_by_id(hash[:sheet_id])

        hash[:rows].each do |sheet_row|
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

          grid_group_variables.each do |variable|
            variable.grid_variables.each do |grid_variable_hash|
              row << (sheet_row[variable.id.to_s].blank? ? '' : sheet_row[variable.id.to_s][grid_variable_hash[:variable_id].to_s])
            end
          end
          csv << row
        end
      end
    end

    ["#{folder.upcase}/#{export_file.split('/').last}", export_file]
  end

end
