desc "Import design, sheets, and variables from CSV"
task design_import: :environment do
  design = Design.find_by_id(ENV["DESIGN_ID"])
  site = design.project.sites.find_by_id(ENV["SITE_ID"])
  # design_scope = Design.current.where(id: ENV["DESIGN_IDS"].to_s.split(','))

  design.create_sheets!(site, ENV["SUBJECT_STATUS"])


end
