# frozen_string_literal: true

require 'pats/core'

module Pats
  # Exports graph and table for consented subjects on PATS.
  module Consented
    include Pats::Core

    def consented_graph(project, start_date)
      graph = {}
      categories = generate_categories_months(start_date)
      series = []
      date_variable = project.variables.find_by(name: 'ciw_consent_date')
      project.sites.each do |site|
        series << {
          name: site.short_name,
          data: by_month_of_attribute(informed_consent_sheets(project).where(subjects: { site_id: site.id }), start_date, date_variable)
        }
      end
      series << {
        name: 'Overall',
        data: by_month_of_attribute(informed_consent_sheets(project), start_date, date_variable),
        visible: false
      }
      graph[:total] = count_subjects(informed_consent_sheets(project))
      graph[:categories] = categories
      graph[:series] = series
      graph[:title] = 'Cumulative Consented'
      graph[:yaxis] = '# Consented'
      # graph[:xaxis] = ''
      graph
    end

    def consented_table(project, start_date)
      objects = informed_consent_sheets(project)
      date_variable = project.variables.find_by(name: 'ciw_consent_date')
      generic_table(project, start_date, 'Consented', objects, date_variable: date_variable)
    end

    def informed_consent_sheets(project)
      consented_sheets(project)
    end
  end
end
