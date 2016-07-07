# frozen_string_literal: true

require 'pats/core'

module Pats
  # Exports graph and table for randomized subjects on PATS.
  module Randomized
    include Pats::Core

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

    def randomized_table(project, start_date)
      objects = randomizations(project)
      generic_table(project, start_date, 'Randomized', objects, attribute: :randomized_at)
    end

    def randomizations(project)
      randomization_scheme_id = project.randomization_schemes.first.id
      # randomization_scheme_id = 12
      project.randomizations.where(randomization_scheme_id: randomization_scheme_id).joins(:subject).merge(Subject.current)
    end

    def randomizations_print(project)
      sheets_by_site_print(project, randomizations(project), 'Randomized')
    end
  end
end
