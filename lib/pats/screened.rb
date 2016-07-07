# frozen_string_literal: true

require 'pats/core'

module Pats
  # Exports graph and table for screened subjects on PATS.
  module Screened
    include Pats::Core

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

    def screened_table(project, start_date)
      objects = ciws(project)
      generic_table(project, start_date, 'Screened', objects)
    end
  end
end
