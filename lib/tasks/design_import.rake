desc "Import design, sheets, and variables from CSV"
task design_import: :environment do
  design = Design.find_by_id(ENV["DESIGN_ID"])
  # design_scope = Design.current.where(id: ENV["DESIGN_IDS"].to_s.split(','))

  design.create_sheets!


end
