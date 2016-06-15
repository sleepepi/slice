# frozen_string_literal: true

namespace :pats do
  desc 'Export recruitment data.'
  task recruitment: :environment do
    recruitment = {}
    slug = 'pats'
    project = Project.current.find_by_slug slug
    start_date = Date.parse('2016-06-01')
    if project
      recruitment[:screened] = screened_graph(project, start_date)
      recruitment[:screened][:table] = screened_table(project, start_date)
      recruitment[:consented] = consented_graph(project, start_date)
      recruitment[:consented][:table] = consented_table(project, start_date)
      recruitment[:eligible] = eligible_graph(project, start_date)
      recruitment[:eligible][:table] = eligible_table(project, start_date)
      recruitment[:randomized] = randomized_graph(project, start_date)
      recruitment[:randomized][:table] = randomized_table(project, start_date)
      recruitment[:exported_at] = Time.zone.now
      recruitment_json_file = Rails.root.join('pats', 'recruitment.json')
      File.open(recruitment_json_file, 'w') do |f|
        f.write(recruitment.to_json)
      end
      puts 'Wrote file to: ' + recruitment_json_file.to_s.colorize(:green)
    else
      puts 'Unable to load project: ' + slug.colorize(:red)
    end
  end
end

def category_time_format
  "%d %b '%y"
end

def screened_graph(project, start_date)
  graph = {}
  categories = generate_categories(start_date)
  series = []
  project.sites.each do |site|
    series << {
      name: site.short_name,
      data: by_week(ciws(project).where(subjects: { site_id: site.id }), start_date)
    }
  end

  graph[:total] = count_subjects(ciws(project))
  graph[:in_pipeline] = count_subjects(eligible_to_continue_to_baseline_sheets(project, response: ''))
  graph[:categories] = categories
  graph[:series] = series
  graph[:title] = 'Cumulative Screened'
  graph[:yaxis] = '# Screened'
  graph[:xaxis] = 'Week Starting On'
  graph
end

def consented_graph(project, start_date)
  graph = {}
  categories = generate_categories(start_date)
  series = []
  date_variable = project.variables.find_by_name 'ciw_consent_date'
  project.sites.each do |site|
    series << {
      name: site.short_name,
      data: by_week_of_attribute(informed_consent_sheets(project).where(subjects: { site_id: site.id }), start_date, date_variable)
    }
  end

  graph[:total] = count_subjects(informed_consent_sheets(project))
  graph[:categories] = categories
  graph[:series] = series
  graph[:title] = 'Cumulative Consented'
  graph[:yaxis] = '# Consented'
  graph[:xaxis] = 'Week Starting On'
  graph
end

def eligible_graph(project, start_date)
  graph = {}
  categories = generate_categories(start_date)
  series = []
  date_variable = project.variables.find_by_name 'ciw_eligibility_date'
  project.sites.each do |site|
    series << {
      name: site.short_name,
      data: by_week_of_attribute(eligible_to_continue_to_baseline_sheets(project).where(subjects: { site_id: site.id }), start_date, date_variable)
    }
  end

  graph[:total] = count_subjects(eligible_to_continue_to_baseline_sheets(project))
  graph[:categories] = categories
  graph[:series] = series
  graph[:title] = 'Cumulative Eligible'
  graph[:yaxis] = '# Eligible'
  graph[:xaxis] = 'Week Starting On'
  graph
end

def randomized_graph(project, start_date)
  graph = {}
  categories = generate_categories(start_date)
  series = []
  project.sites.each do |site|
    series << {
      name: site.short_name,
      data: by_week(randomizations(project).where(subjects: { site_id: site.id }), start_date)
    }
  end

  scheme = project.randomization_schemes.first

  graph[:total] = count_subjects(randomizations(project))
  graph[:randomization_goal] = scheme.randomization_goal
  graph[:scheme_name] = scheme.name
  graph[:categories] = categories
  graph[:series] = series
  graph[:title] = 'Cumulative Randomized'
  graph[:yaxis] = '# Randomized'
  graph[:xaxis] = 'Week Starting On'
  graph
end

def generic_table(project, start_date, type, objects, attribute: :created_at, date_variable: nil)
  table = {}

  header = []
  header_row = ['Week Starting On'] + project.sites.collect(&:short_name) + ['Week Total']
  header << header_row

  footer = []
  footer_row = ["Total #{type}"]
  footer_total = 0
  project.sites.each do |site|
    site_total = count_subjects(objects.where(subjects: { site_id: site.id }))
    footer_total += site_total
    footer_row << site_total
  end
  footer_row << footer_total
  footer << footer_row

  rows = []
  current_week = start_date.beginning_of_week
  last_week = Time.zone.today.beginning_of_week
  total = 0
  while current_week <= last_week
    total_row_count = 0
    row = [current_week.strftime(category_time_format)]
    project.sites.each do |site|
      site_objects = objects.where(subjects: { site_id: site.id })
      week_objects = if date_variable
                      site_objects.joins(:sheet_variables).where('DATE(sheet_variables.response) BETWEEN ? AND ?', current_week.all_week.first, current_week.all_week.last).where(sheet_variables: { variable_id: date_variable.id })
                    else
                      site_objects.where(attribute.to_sym => current_week.all_week)
                    end
      week_count = count_subjects(week_objects)
      total_row_count += week_count
      row << week_count
    end
    row << total_row_count
    rows << row
    total += total_row_count
    current_week += 1.week
  end

  table[:total] = total
  table[:header] = header
  table[:footer] = footer
  table[:rows] = rows
  table[:title] = "#{type} By Week"
  table
end

def screened_table(project, start_date)
  objects = ciws(project)
  generic_table(project, start_date, 'Screened', objects)
end

def consented_table(project, start_date)
  objects = informed_consent_sheets(project)
  date_variable = project.variables.find_by_name 'ciw_consent_date'
  generic_table(project, start_date, 'Consented', objects, date_variable: date_variable)
end

def eligible_table(project, start_date)
  objects = eligible_to_continue_to_baseline_sheets(project)
  date_variable = project.variables.find_by_name 'ciw_eligibility_date'
  generic_table(project, start_date, 'Eligible', objects, date_variable: date_variable)
end

def randomized_table(project, start_date)
  objects = randomizations(project)
  generic_table(project, start_date, 'Randomized', objects, attribute: :randomized_at)
end

def design_id(project)
  # design_id = 476
  design = project.designs.find_by_name 'Child Information Worksheet'
  design_id = design.id
end

def ciws(project)
  design_id = design_id(project)
  project.sheets.where(design_id: design_id, missing: false)
end

def ciws_print(project)
  sheets_by_site_print(project, ciws(project), 'Screened')
end

def informed_consent_sheets(project)
  design_id = design_id(project)
  # answering "1: Yes" to #29 question (Informed Consent) (i.e. "# Consented")
  # variable_id = 14297
  variable = project.variables.find_by_name 'ciw_complete_informed_consent'
  variable_id = variable.id

  # `ciw_consent_date` is date the consent happened.
  sheet_scope = SheetVariable.where(variable_id: variable_id, response: '1').select(:sheet_id)
  project.sheets.where(id: sheet_scope, design_id: design_id, missing: false)
end

def informed_consent_sheets_print(project)
  sheets_by_site_print(project, informed_consent_sheets(project), 'Consented')
end

def eligible_to_continue_to_baseline_sheets(project, response: '1')
  design_id = design_id(project)
  # answering "1: Yes" to #31 question (eligible for baseline) (i.e. "# Eligible to Continue to Baseline")
  # variable_id = 14299
  variable = project.variables.find_by_name 'ciw_eligible_for_baseline'
  variable_id = variable.id

  sheet_scope = SheetVariable.where(variable_id: variable_id, response: response).select(:sheet_id)
  project.sheets.where(id: sheet_scope, design_id: design_id, missing: false)
end

def eligible_to_continue_to_baseline_sheets_print(project)
  sheets_by_site_print(project, eligible_to_continue_to_baseline_sheets(project), 'Eligible to Continue To Baseline')
end

def randomizations(project)
  randomization_scheme_id = project.randomization_schemes.first.id
  # randomization_scheme_id = 12
  project.randomizations.where(randomization_scheme_id: randomization_scheme_id).joins(:subject).merge(Subject.current)
end

def randomizations_print(project)
  sheets_by_site_print(project, randomizations(project), 'Randomized')
end

def sheets_by_site_print(project, sheets, text)
  total_sheets_count = count_subjects(sheets)
  puts "#{text} [Total]: " + total_sheets_count.to_s.colorize(total_sheets_count > 0 ? :green : :white)
  project.sites.each do |site|
    site_sheet_count = count_subjects(sheets.where(subjects: { site_id: site.id }))
    puts "#{text} [#{site.name}]: " + site_sheet_count.to_s.colorize(site_sheet_count > 0 ? :green : :white)
  end
end

def by_week(sheets, start_date)
  data = []
  total_count = 0
  current_week = start_date.beginning_of_week
  last_week = Time.zone.today.beginning_of_week
  while current_week <= last_week
    total_count += count_subjects(sheets.where(created_at: current_week.all_week))
    data << total_count
    current_week += 1.week
  end
  data
end

def by_week_of_attribute(sheets, start_date, variable)
  data = []
  total_count = 0
  current_week = start_date.beginning_of_week
  last_week = Time.zone.today.beginning_of_week
  while current_week <= last_week
    week_sheets = sheets.joins(:sheet_variables).where('DATE(sheet_variables.response) BETWEEN ? AND ?', current_week.all_week.first, current_week.all_week.last).where(sheet_variables: { variable_id: variable.id })
    total_count += count_subjects(week_sheets)
    data << total_count
    current_week += 1.week
  end
  data
end

def count_subjects(sheets)
  sheets.select(:subject_id).distinct.count(:subject_id)
end

def generate_categories(start_date)
  weeks = []
  current_week = start_date.beginning_of_week
  last_week = Time.zone.today.beginning_of_week
  while current_week <= last_week
    weeks << current_week.strftime(category_time_format)
    current_week += 1.week
  end
  weeks
end
