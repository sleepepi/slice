# frozen_string_literal: true

require 'pats/core'

module Pats
  # Exports graph and table for eligible subjects on PATS.
  module Eligible
    include Pats::Core

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

    def eligible_table(project, start_date)
      objects = eligible_to_continue_to_baseline_sheets(project)
      date_variable = project.variables.find_by_name 'ciw_eligibility_date'
      generic_table(project, start_date, 'Eligible', objects, date_variable: date_variable)
    end

    def eligible_to_continue_to_baseline_sheets(project, response: '1')
      eligible_sheets(project, response: response)
    end

    def eligible_to_continue_to_baseline_sheets_print(project)
      sheets_by_site_print(project, eligible_to_continue_to_baseline_sheets(project), 'Eligible to Continue To Baseline')
    end
  end
end
