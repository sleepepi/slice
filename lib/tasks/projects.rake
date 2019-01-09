# frozen_string_literal: true

# rails projects:copy RAILS_ENV=production -- -pPROJECT --no-schemes --no-events

namespace :projects do
  desc "Copy a project to a new blank project"
  task copy: :environment do
    args = ARGV.split("--").last

    options = {
      verbose: false,
      schemes: true,
      events: true
    }

    OptionParser.new do |opts|
      opts.banner = "Usage: rake projects:copy -- [options]"

      opts.on("-p", "--project PROJECT", "Specify PROJECT to copy") do |p|
        options[:project] = p
      end

      opts.on("--[no-]schemes", "Randomization schemes") do |s|
        options[:schemes] = s
      end

      opts.on("--[no-]events", "Events") do |e|
        options[:events] = e
      end

      opts.on("-v", "--verbose", "Run verbosely") do |v|
        puts "GETS v"
        options[:verbose] = v
      end

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    end.parse!(args)

    print "\nConfiguration".underline
    puts " -h for additional options\n"
    puts " Designs: #{"YES".green}"
    puts "  Events: #{options[:events] ? "YES".green : "no".red}"
    puts " Schemes: #{options[:schemes] ? "YES".green : "no".red}"
    puts

    original = Project.current.find_by_param(options[:project]) if options[:project].present?
    if original
      copy = copy_project(original)
      site_map = copy_project_sites(original, copy, options)
      copy_project_users(original, copy, options)
      variable_map = copy_variables(original, copy, site_map, options)
      design_map = copy_designs(original, copy, variable_map, options)
      copy_events(original, copy, design_map, variable_map, options)
      copy_schemes(original, copy, variable_map, options)
      initialize_counters(copy)
      puts "#{ENV["website_url"]}/projects/#{copy.id}".white.underline
    else
      puts "Project Not Found: --project #{options[:project].presence || "PROJECT"}"
    end

    exit 0
  end
end

def copy_project(original)
  Project.create(
    name: "#{original.name} COPY",
    user_id: original.user_id,
    description: original.description,
    logo: original.logo,
    logo_uploaded_at: Time.zone.now,
    subject_code_name: original.subject_code_name,
    disable_all_emails: original.disable_all_emails,
    hide_values_on_pdfs: original.hide_values_on_pdfs,
    randomizations_enabled: original.randomizations_enabled,
    adverse_events_enabled: original.adverse_events_enabled,
    blinding_enabled: original.blinding_enabled,
    handoffs_enabled: original.handoffs_enabled,
    auto_lock_sheets: original.auto_lock_sheets,
    translations_enabled: original.translations_enabled
  )
end

def copy_project_sites(original, copy, options)
  site_map = {}
  copy.sites.destroy_all
  sites_count = original.sites.count
  if options[:verbose]
    puts "Sites: #{sites_count}"
  else
    print "Sites: 0 of 0"
  end
  original.sites.each_with_index do |s, index|
    sc = copy.sites.create(
      name: s.name,
      description: s.description,
      user_id: s.user_id,
      subject_code_format: s.subject_code_format
    )
    site_map[s.id.to_s] = sc.id
    if options[:verbose]
      puts "Added #{sc.name.white} site"
    else
      print "\rSites: #{counter(index, sites_count)}"
    end
  end
  puts "" unless options[:verbose]
  site_map
end

def copy_project_users(original, copy, options)
  members_count = original.project_users.count
  if options[:verbose]
    puts "Team members: #{members_count}"
  else
    print "Team members: 0 of 0"
  end
  original.project_users.where.not(user_id: nil).each_with_index do |pu, index|
    copy.project_users.create(
      user_id: pu.user_id,
      editor: pu.editor,
      creator_id: pu.creator_id,
      unblinded: pu.unblinded
    )
    if options[:verbose]
      puts "Added #{pu.user.full_name.white} as project #{pu.editor ? "editor" : "viewer"}"
    else
      print "\rTeam members: #{counter(index, members_count)}"
    end
  end
  puts "" unless options[:verbose]
end

def copy_variables(original, copy, site_map, options)
  domain_map = {}
  variable_map = {}
  domains_count = original.domains.count
  if options[:verbose]
    puts "Domains: #{domains_count}"
  else
    print "Domains: 0 of 0"
  end
  original.domains.each_with_index do |d, index|
    dc = copy.domains.create(
      name: d.name,
      display_name: d.display_name,
      description: d.description,
      user_id: d.user_id
    )
    d.domain_options.each do |domain_option|
      domain_option_copy = dc.domain_options.create(
        name: domain_option.name,
        value: domain_option.value,
        description: domain_option.description,
        site_id: site_map[domain_option.site_id.to_s],
        missing_code: domain_option.missing_code,
        archived: domain_option.archived,
        position: domain_option.position
      )
      copy_translations(domain_option, domain_option_copy)
    end
    domain_map[d.id.to_s] = dc.id
    copy_translations(d, dc)
    if options[:verbose]
      puts "Added #{dc.name.white} domain"
    else
      print "\rDomains: #{counter(index, domains_count)}"
    end
  end
  puts "" unless options[:verbose]

  variables_count = original.variables.count
  if options[:verbose]
    puts "Variables: #{variables_count}"
  else
    print "Variables: 0 of 0"
  end
  non_grid_variables_count = original.variables.where.not(variable_type: "grid").count

  original.variables.where.not(variable_type: "grid").each_with_index do |v, index|
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
      calculated_format: v.calculated_format,
      units: v.units,
      multiple_rows: v.multiple_rows,
      autocomplete_values: v.autocomplete_values,
      prepend: v.prepend,
      append: v.append,
      show_current_button: v.show_current_button,
      display_layout: v.display_layout,
      alignment: v.alignment,
      default_row_number: v.default_row_number,
      scale_type: v.scale_type,
      domain_id: domain_map[v.domain_id.to_s],
      time_of_day_format: v.time_of_day_format,
      show_seconds: v.show_seconds,
      time_duration_format: v.time_duration_format,
      date_format: v.date_format,
      hide_calculation: v.hide_calculation
    )
    vc.update_column :calculation, v.readable_calculation
    variable_map[v.id.to_s] = vc.id
    copy_translations(v, vc)
    if options[:verbose]
      puts "Added #{vc.name.white} variable"
    else
      print "\rVariables: #{counter(index, variables_count)}"
    end
  end

  original.variables.where(variable_type: "grid").each_with_index do |v, index|
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
      calculated_format: v.calculated_format,
      units: v.units,
      multiple_rows: v.multiple_rows,
      autocomplete_values: v.autocomplete_values,
      prepend: v.prepend,
      append: v.append,
      show_current_button: v.show_current_button,
      display_layout: v.display_layout,
      alignment: v.alignment,
      default_row_number: v.default_row_number,
      scale_type: v.scale_type,
      domain_id: domain_map[v.domain_id.to_s],
      time_of_day_format: v.time_of_day_format,
      show_seconds: v.show_seconds,
      time_duration_format: v.time_duration_format,
      date_format: v.date_format,
      hide_calculation: v.hide_calculation
    )
    vc.update_column :calculation, v.readable_calculation
    v.child_grid_variables.each_with_index do |child_grid_variable, index|
      vc.child_grid_variables.create(
        project_id: copy.id,
        child_variable_id: variable_map[child_grid_variable.child_variable_id.to_s],
        position: index
      )
    end
    variable_map[v.id.to_s] = vc.id
    copy_translations(v, vc)
    if options[:verbose]
      puts "Added #{vc.name.white} variable"
    else
      print "\rVariables: #{counter(index + non_grid_variables_count, variables_count)}"
    end
  end
  puts "" unless options[:verbose]

  copy.variables.find_each { |v| v.update calculation: v.readable_calculation }
  variable_map
end

def copy_sections(design, design_copy, options)
  section_map = {}
  sections_count = design.sections.count
  puts "Sections: #{sections_count}" if options[:verbose]
  design.sections.each do |section|
    section_copy = design_copy.sections.create(
      project_id: design_copy.project_id,
      name: section.name,
      description: section.description,
      level: section.level,
      image: section.image,
      user_id: section.user_id
    )
    section_map[section.id.to_s] = section_copy.id
    copy_translations(section, section_copy)
    puts "Added #{(section_copy.name.presence || section_copy.description).to_s.white} section" if options[:verbose]
  end
  section_map
end

def copy_categories(original, copy, options)
  category_map = {}
  copy.categories.destroy_all
  categories_count = original.categories.count
  if options[:verbose]
    puts "Categories: #{categories_count}"
  else
    print "Categories: 0 of 0"
  end
  original.categories.each_with_index do |c, index|
    cc = copy.categories.create(
      use_for_adverse_events: c.use_for_adverse_events,
      name: c.name,
      slug: c.slug,
      position: c.position,
      description: c.description,
      user_id: c.user_id
    )
    category_map[c.id.to_s] = cc.id
    if options[:verbose]
      puts "Added #{cc.name.white} category"
    else
      print "\rCategories: #{counter(index, categories_count)}"
    end
  end
  puts "" unless options[:verbose]
  category_map
end

def copy_designs(original, copy, variable_map, options)
  design_map = {}
  category_map = copy_categories(original, copy, options)
  designs_count = original.designs.count
  if options[:verbose]
    puts "Designs: #{designs_count}"
  else
    print "Designs: 0 of 0"
  end
  original.designs.each_with_index do |d, index|
    dc = copy.designs.create(
      name: d.name,
      slug: d.slug,
      short_name: d[:short_name].presence,
      publicly_available: d.publicly_available,
      redirect_url: d.redirect_url,
      show_site: d.show_site,
      category_id: category_map[d.category_id.to_s],
      only_unblinded: d.only_unblinded,
      user_id: d.user_id
    )
    section_map = copy_sections(d, dc, options)
    d.design_options.each do |design_option|
      design_option_copy = dc.design_options.create(
        variable_id: variable_map[design_option.variable_id.to_s],
        section_id: section_map[design_option.section_id.to_s],
        position: design_option.position,
        requirement: design_option.requirement
      )
      design_option_copy.update(branching_logic: design_option.readable_branching_logic)
      copy_translations(design_option, design_option_copy)
    end
    design_map[d.id.to_s] = dc.id

    copy_translations(d, dc)

    if options[:verbose]
      puts "Added #{dc.name.white} design"
    else
      print "\rDesigns: #{counter(index, designs_count)}"
    end
  end
  puts "" unless options[:verbose]
  design_map
end

def copy_schemes(original, copy, variable_map, options)
  return unless options[:schemes]

  schemes_count = original.randomization_schemes.count
  if options[:verbose]
    puts "Schemes: #{schemes_count}"
  else
    print "Schemes: 0 of 0"
  end
  original.randomization_schemes.each_with_index do |rs, index|
    rsc = copy.randomization_schemes.create(
      name: rs.name,
      description: rs.description,
      user_id: rs.user_id,
      randomization_goal: rs.randomization_goal,
      algorithm: rs.algorithm,
      chance_of_random_treatment_arm_selection: rs.chance_of_random_treatment_arm_selection,
      variable_id: variable_map[rs.variable_id.to_s],
      variable_value: rs.variable_value
    )
    copy_block_size_multipliers(rs, rsc, options)
    copy_stratification_factors(rs, rsc, options)
    copy_treatment_arms(rs, rsc, options)
    rsc.generate_lists!(rsc.user)
    rsc.update(published: rs.published)
    if options[:verbose]
      puts "Added #{rsc.name.white} randomization scheme"
    else
      print "\rSchemes: #{counter(index, schemes_count)}"
    end
  end
  puts "" unless options[:verbose]
end

def copy_block_size_multipliers(rs, rsc, options)
  puts "Block Size Multipliers: #{rs.block_size_multipliers.count}" if options[:verbose]
  rs.block_size_multipliers.each do |bsm|
    bsmc = rsc.block_size_multipliers.create(
      project_id: rsc.project_id,
      user_id: bsm.user_id,
      value: bsm.value,
      allocation: bsm.allocation
    )
    puts "Added #{bsmc.name.white} block size multiplier" if options[:verbose]
  end
end

def copy_stratification_factors(rs, rsc, options)
  puts "Stratification Factors: #{rs.stratification_factors.count}" if options[:verbose]
  rs.stratification_factors.each do |sf|
    sfc = rsc.stratification_factors.create(
      project_id: rsc.project_id,
      user_id: sf.user_id,
      name: sf.name,
      stratifies_by_site: sf.stratifies_by_site,
      calculation: sf.readable_calculation
    )
    copy_stratification_factor_options(sf, sfc, options)
    puts "Added #{sfc.name.white} stratification factor" if options[:verbose]
  end
end

def copy_stratification_factor_options(sf, sfc, options)
  puts "Stratification Factor Options: #{sf.stratification_factor_options.count}" if options[:verbose]
  sf.stratification_factor_options.each do |sfo|
    sfoc = sfc.stratification_factor_options.create(
      project_id: sfc.project_id,
      randomization_scheme_id: sfc.randomization_scheme_id,
      user_id: sfo.user_id,
      label: sfo.label,
      value: sfo.value
    )
    puts "Added #{sfoc.name.white} stratification factor option" if options[:verbose]
  end
end

def copy_treatment_arms(rs, rsc, options)
  puts "Treatment Arms: #{rs.treatment_arms.count}" if options[:verbose]
  rs.treatment_arms.each do |ta|
    tac = rsc.treatment_arms.create(
      project_id: rsc.project_id,
      name: ta.name,
      allocation: ta.allocation,
      user_id: ta.user_id
    )
    puts "Added #{tac.name.white} treatment arms" if options[:verbose]
  end
end

def copy_events(original, copy, design_map, variable_map, options)
  return unless options[:events]

  event_map = {}
  event_copies = {}
  events_count = original.events.count
  if options[:verbose]
    puts "Events: #{events_count}"
  else
    print "Events: 0 of 0"
  end
  original.events.each do |event|
    event_copy = copy.events.create(
      name: event.name,
      description: event.description,
      user_id: event.user_id,
      archived: event.archived,
      position: event.position,
      slug: event.slug
    )
    event_map[event.id.to_s] = event_copy.id
    event_copies[event.id.to_s] = event_copy
    copy_translations(event, event_copy)
  end

  original.events.each_with_index do |event, index|
    event_copy = event_copies[event.id.to_s]
    copy_event_designs(event, event_copy, event_map, design_map, variable_map, options)

    if options[:verbose]
      puts "Added #{event_copy.name.white} event"
    else
      print "\rEvents: #{counter(index, events_count)}"
    end
  end

  puts "" unless options[:verbose]
end

def copy_event_designs(event, event_copy, event_map, design_map, variable_map, options)
  puts "Event Designs: #{event.event_designs.count}" if options[:verbose]
  event.event_designs.each do |event_design|
    event_design_copy = event_copy.event_designs.create(
      design_id: design_map[event_design.design_id.to_s],
      position: event_design.position,
      handoff_enabled: event_design.handoff_enabled,
      requirement: event_design.requirement,
      conditional_event_id: event_map[event_design.conditional_event_id.to_s],
      conditional_design_id: design_map[event_design.conditional_design_id.to_s],
      conditional_variable_id: variable_map[event_design.conditional_variable_id.to_s],
      conditional_value: event_design.conditional_value,
      conditional_operator: event_design.conditional_operator,
      duplicates: event_design.duplicates
    )
    puts "Added #{event_design_copy.design.name.white} event design" if options[:verbose]
  end
end

def initialize_counters(copy)
  copy.domains.find_each { |domain| Domain.reset_counters(domain.id, :variables) }
  copy.subjects.find_each { |subject| Subject.reset_counters(subject.id, :randomizations) }
  copy.designs.find_each(&:recompute_variables_count!)
end

def counter(index, total)
  "#{counter_string(index, total)} #{percent_string(index, total)}"
end

def counter_string(index, total)
  "#{index + 1} of #{total}"
end

def percent_string(index, total)
  return "(100%)  " if total.zero? || (index + 1 == total)

  format("(%0.1f%%)", ((index + 1) * 100.0 / total))
end

def copy_translations(original, copy)
  original.translations.each do |translation|
    Translation.create(
      translatable_id: copy.id,
      translatable_type: translation.translatable_type,
      translatable_attribute: translation.translatable_attribute,
      language_code: translation.language_code,
      translation: translation.translation
    )
  end
end
