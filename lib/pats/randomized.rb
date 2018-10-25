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
        lineWidth: 3,
        visible: false
      }
      series << expectected_randomization_series(start_date)
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

    def expectected_randomization_series(start_date)
      line = {
        name: 'Overall Expected',
        visible: false,
        dashStyle: 'shortdot'
      }
      points = []
      current_month = start_date.beginning_of_month - 1.month
      last_month = Time.zone.today.beginning_of_month
      index = -1
      while current_month <= last_month
        index += 1
        points << expected_total_array[index] || 0
        current_month += 1.month
      end
      line[:data] = points
      line
    end

    def randomized_table(project, start_date)
      objects = randomizations(project)
      generic_table(project, start_date, 'Randomized', objects, attribute: :randomized_at)
    end

    def expected_total_array
      [
        0,
        0,
        2.6666, 5.33333, 8,
        13.33333, 18.66666, 24,
        31.333333, 38.666666, 46,
        56, 66, 76,
        86.66666666, 97.333333, 108,
        118.6666667, 129.3333333, 140,
        150.6666667, 161.3333333, 172,
        182.6666667, 193.3333333, 204,
        214.6666667, 225.3333333, 236,
        246.6666667, 257.3333333, 268,
        278.6666667, 289.3333333, 300,
        310.6666667, 321.3333333, 332,
        342.6666667, 353.3333333, 364,
        374.6666667, 385.3333333, 396,
        406.6666667, 417.3333333, 428,
        438.6666667, 449.3333333, 460
      ]
    end
  end
end
