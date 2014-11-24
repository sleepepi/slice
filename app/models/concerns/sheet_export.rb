module SheetExport
  extend ActiveSupport::Concern

  def generate_csv_sheets(sheet_scope, filename, raw_data, folder)
    generate_csv_sheets_internal(sheet_scope, filename, raw_data, folder)
  end

  private

  def generate_csv_sheets_internal(sheet_scope, filename, raw_data, folder)
    export_file = File.join('tmp', 'files', 'exports', "#{filename}_#{raw_data ? 'raw' : 'labeled'}.csv")

    rows = []

    sheet_scope.each do |sheet|
      hash = { sheet_id: sheet.id }
      sheet.sheet_variables.each do |sv|
        unless sv.variable.variable_type == 'grid'
          response = (raw_data ? sv.get_response(:raw) : sv.get_response(:name))
          hash[sv.variable_id.to_s] = response
          hash[sv.variable_id.to_s] = hash[sv.variable_id.to_s].join(',') if hash[sv.variable_id.to_s].kind_of?(Array)
          if sv.variable.variable_type == 'checkbox'
            sv.variable.shared_options.each_with_index do |option, index|
              search_string = (raw_data ? option[:value] : "#{option[:value]}: #{option[:name]}")
              hash["#{sv.variable_id.to_s}__#{option[:value]}"] = search_string if response.include?(search_string)
            end
          end
        end
      end
      rows << hash
      update_steps(1)
    end

    CSV.open(export_file, "wb") do |csv|
      variables = all_design_variables_without_grids(sheet_scope)
      column_headers = variables.collect(&:csv_column).flatten
      column_ids = variables.collect(&:csv_column_ids).flatten
      csv << ["Sheet ID", "Name", "Description", "Sheet Creation Date", "Project", "Site", "Subject", "Acrostic", "Status", "Creator", "Schedule Name", "Event Name"] + column_headers
      rows.each do |hash|
        sheet = sheet_scope.find_by_id(hash[:sheet_id])
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
        column_ids.each do |column_id|
          row << hash[column_id]
        end
        csv << row
      end
    end
    ["#{folder.upcase}/#{export_file.split('/').last}", export_file]
  end

end
