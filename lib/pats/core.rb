# frozen_string_literal: true

module Pats
  module Core
    def design_id(project)
      # design_id = 476
      design = project.designs.find_by_name 'Child Information Worksheet'
      design_id = design.id
    end

    def category_time_format
      "%d %b '%y"
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

    def ciws(project)
      design_id = design_id(project)
      project.sheets.where(design_id: design_id, missing: false)
    end

    def ciws_print(project)
      sheets_by_site_print(project, ciws(project), 'Screened')
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
  end
end
