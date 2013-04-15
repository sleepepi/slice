desc "Generate file for sheet exports"
task sheet_export: :environment do
  export = Export.find_by_id(ENV["EXPORT_ID"])
  sheet_scope = Sheet.current.where(id: ENV["SHEET_IDS"].to_s.split(',')).joins(:design).order('designs.name, sheets.created_at')

  export.generate_export!(sheet_scope) if export
end
