# frozen_string_literal: true

namespace :projects do
  desc 'Copy a project to a new blank project'
  task copy: :environment do
    project_id = ARGV[1].to_s.gsub('PROJECT=', '')
    original = Project.current.find_by_param project_id
    if original
      copy = copy_project(original)
      copy_project_sites(original, copy)
      copy_project_users(original, copy)
      variable_map = copy_variables(original, copy)
      design_map = copy_designs(original, copy, variable_map)
      copy_schemes(original, copy, variable_map)
      copy_events(original, copy, design_map)
      puts "Project ID: #{copy.id}"
    else
      puts 'Project Not Found'
    end
  end
end

def copy_project(original)
  Project.create(
    name: "#{original.name} COPY",
    user_id: original.user_id,
    description: original.description,
    logo: original.logo,
    subject_code_name: original.subject_code_name,
    show_posts: original.show_posts,
    show_documents: original.show_documents,
    show_contacts: original.show_contacts,
    disable_all_emails: original.disable_all_emails,
    collect_email_on_surveys: original.collect_email_on_surveys,
    lockable: original.lockable,
    hide_values_on_pdfs: original.hide_values_on_pdfs,
    randomizations_enabled: original.randomizations_enabled,
    adverse_events_enabled: original.adverse_events_enabled,
    blinding_enabled: original.blinding_enabled,
    handoffs_enabled: original.handoffs_enabled
  )
end

def copy_project_sites(original, copy)
  copy.sites.destroy_all
  puts "Sites: #{original.sites.count}"
  original.sites.each do |s|
    sc = copy.sites.create(
      name: s.name,
      description: s.description,
      user_id: s.user_id,
      subject_code_format: s.subject_code_format
    )
    puts "Added #{sc.name.colorize(:white)} site"
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
      domain_id: domain_map[v.domain_id.to_s],
      show_seconds: v.show_seconds,
      time_duration_format: v.time_duration_format,
      hide_calculation: v.hide_calculation
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
      domain_id: domain_map[v.domain_id.to_s],
      show_seconds: v.show_seconds,
      time_duration_format: v.time_duration_format,
      hide_calculation: v.hide_calculation
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
      level: s.level,
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

def copy_designs(original, copy, variable_map)
  design_map = {}
  category_map = copy_categories(original, copy)
  puts "Designs: #{original.designs.count}"
  original.designs.each do |d|
    dc = copy.designs.create(
      name: d.name,
      description: d.description,
      publicly_available: d.publicly_available,
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
    design_map[d.id.to_s] = dc.id
    puts "Added #{dc.name.colorize(:white)} design"
  end
  design_map
end

def copy_schemes(original, copy, variable_map)
  puts "Schemes: #{original.randomization_schemes.count}"
  original.randomization_schemes.each do |rs|
    rsc = copy.randomization_schemes.create(
      name: rs.name,
      description: rs.description,
      user_id: rs.user_id,
      published: rs.published,
      randomization_goal: rs.randomization_goal,
      algorithm: rs.algorithm,
      chance_of_random_treatment_arm_selection: rs.chance_of_random_treatment_arm_selection,
      variable_id: variable_map[rs.variable_id.to_s],
      variable_value: rs.variable_value
    )
    copy_block_size_multipliers(rs, rsc)
    copy_stratification_factors(rs, rsc)
    copy_treatment_arms(rs, rsc)
    rsc.generate_lists!(rsc.user)
    puts "Added #{rsc.name.colorize(:white)} randomization scheme"
  end
end

def copy_block_size_multipliers(rs, rsc)
  puts "Block Size Multipliers: #{rs.block_size_multipliers.count}"
  rs.block_size_multipliers.each do |bsm|
    bsmc = rsc.block_size_multipliers.create(
      project_id: rsc.project_id,
      user_id: bsm.user_id,
      value: bsm.value,
      allocation: bsm.allocation
    )
    puts "Added #{bsmc.name.colorize(:white)} block size multiplier"
  end
end

def copy_stratification_factors(rs, rsc)
  puts "Stratification Factors: #{rs.stratification_factors.count}"
  rs.stratification_factors.each do |sf|
    sfc = rsc.stratification_factors.create(
      project_id: rsc.project_id,
      user_id: sf.user_id,
      name: sf.name,
      stratifies_by_site: sf.stratifies_by_site,
      calculation: sf.calculation
    )
    copy_stratification_factor_options(sf, sfc)
    puts "Added #{sfc.name.colorize(:white)} stratification factor"
  end
end

def copy_stratification_factor_options(sf, sfc)
  puts "Stratification Factor Options: #{sf.stratification_factor_options.count}"
  sf.stratification_factor_options.each do |sfo|
    sfoc = sfc.stratification_factor_options.create(
      project_id: sfc.project_id,
      randomization_scheme_id: sfc.randomization_scheme_id,
      user_id: sfo.user_id,
      label: sfo.label,
      value: sfo.value
    )
    puts "Added #{sfoc.name.colorize(:white)} stratification factor option"
  end
end

def copy_treatment_arms(rs, rsc)
  puts "Treatment Arms: #{rs.treatment_arms.count}"
  rs.treatment_arms.each do |ta|
    tac = rsc.treatment_arms.create(
      project_id: rsc.project_id,
      name: ta.name,
      allocation: ta.allocation,
      user_id: ta.user_id
    )
    puts "Added #{tac.name.colorize(:white)} treatment arms"
  end
end

def copy_events(original, copy, design_map)
  puts "Events: #{original.events.count}"
  original.events.each do |e|
    ec = copy.events.create(
      name: e.name,
      description: e.description,
      user_id: e.user_id,
      archived: e.archived,
      position: e.position,
      scheduled: e.scheduled,
      slug: e.slug
    )
    copy_event_designs(e, ec, design_map)
    puts "Added #{ec.name.colorize(:white)} event"
  end
end

def copy_event_designs(e, ec, design_map)
  puts "Event Designs: #{e.event_designs.count}"
  e.event_designs.each do |ed|
    edc = ec.event_designs.create(
      design_id: design_map[ed.design_id.to_s],
      position: ed.position,
      handoff_enabled: ed.handoff_enabled
    )
    puts "Added #{edc.design.name.colorize(:white)} event design"
  end
end
