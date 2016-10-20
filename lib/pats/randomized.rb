# frozen_string_literal: true

require 'pats/core'

module Pats
  # Exports graph and table for randomized subjects on PATS.
  module Randomized
    include Pats::Core

    def randomized_graph(project, start_date)
      graph = {}
      categories = generate_categories_months(start_date)
      series = []
      project.sites.each do |site|
        series << {
          name: site.short_name,
          data: by_month(randomizations(project).where(subjects: { site_id: site.id }), start_date)
        }
      end
      series << {
        name: 'Overall',
        data: by_month(randomizations(project), start_date),
        visible: false
      }
      scheme = project.randomization_schemes.first
      graph[:total] = count_subjects(randomizations(project))
      graph[:randomization_goal] = scheme.randomization_goal
      graph[:scheme_name] = scheme.name
      graph[:categories] = categories
      graph[:series] = series
      graph[:title] = 'Cumulative Randomized'
      graph[:yaxis] = '# Randomized'
      # graph[:xaxis] = ''
      graph
    end

    def randomized_table(project, start_date)
      objects = randomizations(project)
      generic_table(project, start_date, 'Randomized', objects, attribute: :randomized_at)
    end

    def randomizations_print(project)
      sheets_by_site_print(project, randomizations(project), 'Randomized')
    end
  end
end
