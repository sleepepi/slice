# frozen_string_literal: true

namespace :projects do
  desc 'Copy a project to a new blank project'
  task copy: :environment do
    project_id = ARGV[1].to_s.gsub('PROJECT=', '')
    original = Project.current.find_by_param project_id
    if original
      copy = Project.create(name: "#{original.name} COPY", user_id: original.user_id)
      copy_project_users(original, copy)
      copy_designs(original, copy)

    else
      puts 'Project Not Found'
    end
  end
end

def copy_project_users(original, copy)
  puts "Project Users: #{original.project_users.count}"
  original.project_users.where.not(user_id: nil).each do |pu|
    copy.project_users.create(
      user_id: pu.user_id,
      editor: pu.editor,
      creator_id: pu.creator_id,
      unblinded: pu.unblinded
    )
    puts "Added #{pu.user.name.colorize(:white)} as project #{pu.editor ? 'editor' : 'viewer'}"
  end
end

def copy_variables(original, copy)
  domain_map = {}
  variable_map = {}
  puts "Domains: #{original.domains.count}"
  original.domains.each do |d|
    dc = copy.domains.create(
      name: d.name,
      display_name: d.display_name,
      description: d.description,
      options: d.options,
      user_id: d.user_id
    )
    domain_map[d.id.to_s] = dc.id
    puts "Added #{dc.name.colorize(:white)} domain"
  end
  puts "Variables: #{original.variables.count}"
  original.variables.where.not(variable_type: 'grid').each do |v|
    vc = copy.variables.create(
      display_name: v.display_name,
      description: v.description,
      header: v.header,
      variable_type: v.variable_type,
      user_id: v.user_id,
      hard_minimum: v.hard_minimum,
      hard_maximum: v.hard_maximum,
      name: v.name,
      date_hard_maximum: v.date_hard_maximum,
      date_hard_minimum: v.date_hard_minimum,
      date_soft_maximum: v.date_soft_maximum,
      date_soft_minimum: v.date_soft_minimum,
      soft_maximum: v.soft_maximum,
      soft_minimum: v.soft_minimum,
      calculation: v.calculation,
      format: v.format,
      units: v.units,
      multiple_rows: v.multiple_rows,
      autocomplete_values: v.autocomplete_values,
      prepend: v.prepend,
      append: v.append,
      show_current_button: v.show_current_button,
      display_name_visibility: v.display_name_visibility,
      alignment: v.alignment,
      default_row_number: v.default_row_number,
      scale_type: v.scale_type,
      domain_id: domain_map[v.domain_id.to_s]
    )
    variable_map[v.id.to_s] = vc.id
    puts "Added #{vc.name.colorize(:white)} variable"
  end
  original.variables.where(variable_type: 'grid').each do |v|
    vc = copy.variables.create(
      display_name: v.display_name,
      description: v.description,
      header: v.header,
      variable_type: v.variable_type,
      user_id: v.user_id,
      hard_minimum: v.hard_minimum,
      hard_maximum: v.hard_maximum,
      name: v.name,
      date_hard_maximum: v.date_hard_maximum,
      date_hard_minimum: v.date_hard_minimum,
      date_soft_maximum: v.date_soft_maximum,
      date_soft_minimum: v.date_soft_minimum,
      soft_maximum: v.soft_maximum,
      soft_minimum: v.soft_minimum,
      calculation: v.calculation,
      format: v.format,
      units: v.units,
      grid_variables: v.grid_variables.collect { |h| { variable_id: variable_map[h[:variable_id].to_s] } },
      multiple_rows: v.multiple_rows,
      autocomplete_values: v.autocomplete_values,
      prepend: v.prepend,
      append: v.append,
      show_current_button: v.show_current_button,
      display_name_visibility: v.display_name_visibility,
      alignment: v.alignment,
      default_row_number: v.default_row_number,
      scale_type: v.scale_type,
      domain_id: domain_map[v.domain_id.to_s]
    )
    variable_map[v.id.to_s] = vc.id
    puts "Added #{vc.name.colorize(:white)} variable"
  end
  variable_map
end

def copy_sections(d, dc)
  section_map = {}
  puts "Sections: #{d.sections.count}"
  d.sections.each do |s|
    puts
    sc = dc.sections.create(
      project_id: dc.project_id,
      name: s.name,
      description: s.description,
      sub_section: s.sub_section,
      branching_logic: s.branching_logic,
      image: s.image,
      user_id: s.user_id
    )
    section_map[s.id.to_s] = sc.id
    puts "Added #{sc.name.colorize(:white)} section"
  end
  section_map
end

def copy_categories(original, copy)
  category_map = {}
  copy.categories.destroy_all
  puts "Categories: #{original.categories.count}"
  original.categories.each do |c|
    cc = copy.categories.create(
      use_for_adverse_events: c.use_for_adverse_events,
      name: c.name,
      slug: c.slug,
      position: c.position,
      description: c.description,
      user_id: c.user_id
    )
    category_map[c.id.to_s] = cc.id
    puts "Added #{cc.name.colorize(:white)} category"
  end
  category_map
end

def copy_designs(original, copy)
  category_map = copy_categories(original, copy)
  variable_map = copy_variables(original, copy)
  puts "Designs: #{original.designs.count}"
  original.designs.each do |d|
    dc = copy.designs.create(
      name: d.name,
      description: d.description,
      publicly_available: d.publicly_available,
      slug: d.slug,
      redirect_url: d.redirect_url,
      show_site: d.show_site,
      category_id: category_map[d.category_id.to_s],
      only_unblinded: d.only_unblinded,
      user_id: d.user_id
    )
    section_map = copy_sections(d, dc)
    d.design_options.each do |design_option|
      dc.design_options.create(
        variable_id: variable_map[design_option.variable_id.to_s],
        section_id: section_map[design_option.section_id.to_s],
        position: design_option.position,
        required: design_option.required,
        branching_logic: design_option.branching_logic
      )
    end

    puts "Added #{dc.name.colorize(:white)} design"
  end
end
