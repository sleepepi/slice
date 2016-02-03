# frozen_string_literal: true

namespace :designs do

  desc 'Migrate options to new database relationships'
  task migrate_options: :environment do
    puts 'Migrating design options to new relationships.'

    # puts "Design Options: #{DesignOption.count}"
    # ActiveRecord::Base.connection.execute("TRUNCATE design_options RESTART IDENTITY")
    # puts "Design Options: #{DesignOption.count}"

    Design.current.each do |design|
      variables = design.project.variables.where(id: design.options.collect { |option| option[:variable_id] }).to_a
      sections = design.project.sections.where(name: design.options.collect { |option| option[:section_name].to_s[0..254] }).to_a
      # puts "#{design.name} has #{variables.count} variables and #{sections.count} sections."
      # puts "#{ENV['website_url']}/projects/#{design.project.to_param}/designs/#{design.to_param}"
      design.options.each_with_index do |option, position|
        if option[:variable_id].blank?
          if section = sections.select { |s| s.name == option[:section_name].to_s[0..254] }.first
            section.update sub_section: (option[:section_type].to_s == '1')
          else
            puts "WARNING NO SECTION FOUND for '#{option[:section_name][0..254]}'"
            if option[:section_name].size > 255
              name = option[:section_name][0..254]
              description = option[:section_name][255..-1]
            else
              name = option[:section_name]
              description = nil
            end
            section = design.sections.create(project_id: design.project_id, user_id: design.user_id, name: name, description: description, sub_section: option[:section_type].to_s == '1')
          end
          design.design_options.create(section_id: section.id, position: position, required: option[:required], branching_logic: option[:branching_logic]) if section and section.valid?
        else
          if variable = variables.select { |v| v.id == option[:variable_id].to_i }.first
            design.design_options.create(variable_id: variable.id, position: position, required: option[:required], branching_logic: option[:branching_logic])
          else
            puts "WARNING NO VARIABLE FOUND for '#{option[:variable_id]}'"
          end
        end
      end
    end

    puts "Design Options: #{DesignOption.count}"
  end
end
