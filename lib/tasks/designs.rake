# frozen_string_literal: true

# TODO: Remove in v0.46.0
namespace :designs do
  desc 'Migrate design descriptions'
  task migrate_descriptions: :environment do
    Design.current.where.not(description: [nil, '']).each do |design|
      puts "#{design.name}: #{design.description}\n"
      section = design.user.sections
                      .where(project_id: design.project_id, design_id: design.id)
                      .create(description: design.description, level: 1)
      design_option = design.design_options.create(section_id: section.id, position: 0)
      design.insert_new_design_option!(design_option)
      design.update description: nil
    end
  end
end
# END: TODO
