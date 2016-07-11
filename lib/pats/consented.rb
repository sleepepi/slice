# frozen_string_literal: true

require 'pats/core'

module Pats
  # Exports graph and table for consented subjects on PATS.
  module Consented
    include Pats::Core

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

    def consented_table(project, start_date)
      objects = informed_consent_sheets(project)
      date_variable = project.variables.find_by_name 'ciw_consent_date'
      generic_table(project, start_date, 'Consented', objects, date_variable: date_variable)
    end

    def informed_consent_sheets(project)
      consented_sheets(project)
    end

    def informed_consent_sheets_print(project)
      sheets_by_site_print(project, informed_consent_sheets(project), 'Consented')
    end
  end
end
