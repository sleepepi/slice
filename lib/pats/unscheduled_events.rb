# frozen_string_literal: true

require 'pats/core'

module Pats
  # Export grades for each site.
  module UnscheduledEvents
    include Pats::Core

    def adverse_events(project)
      project.adverse_events.joins(:subject).where(subjects: { deleted: false })
    end

    def adverse_events_data(project, start_date)
      {
        table: adverse_events_table(project, start_date),
        graph: adverse_events_graph(project, start_date)
      }
    end

    def adverse_events_table(project, start_date)
      objects = adverse_events(project)
      generic_table(project, start_date, 'Adverse Events', objects, attribute: :adverse_event_date, by_distinct_subject: false)
    end

    def adverse_events_graph(project, start_date)
      graph = {}
      categories = generate_categories_months(start_date)
      series = []
      project.sites.each do |site|
        series << {
          name: site.short_name,
          data: by_month(adverse_events(project).where(subjects: { site_id: site.id }), start_date, attribute: :adverse_event_date, running_total: false, by_distinct_subject: false)
        }
      end
      series << {
        name: 'Overall',
        data: by_month(adverse_events(project), start_date, attribute: :adverse_event_date, running_total: false, by_distinct_subject: false),
        lineWidth: 3,
        visible: false
      }
      graph[:total] = count_subjects(adverse_events(project))
      graph[:categories] = categories
      graph[:series] = series
      graph[:title] = 'Adverse Events'
      graph[:yaxis] = '# Adverse Events'
      # graph[:xaxis] = ''
      graph
    end

    def protocol_deviations(project)
      design = project.designs.find_by(short_name: 'PDEV')
      project.sheets.where(design: design, missing: false).joins(:subject).where(subjects: { deleted: false })
    end

    def protocol_deviations_data(project, start_date)
      {
        table: protocol_deviations_table(project, start_date),
        graph: protocol_deviations_graph(project, start_date)
      }
    end

    def protocol_deviations_table(project, start_date)
      objects = protocol_deviations(project)
      generic_table(project, start_date, 'Protocol Deviations', objects, by_distinct_subject: false)
    end

    def protocol_deviations_graph(project, start_date)
      graph = {}
      categories = generate_categories_months(start_date)
      series = []
      project.sites.each do |site|
        series << {
          name: site.short_name,
          data: by_month(protocol_deviations(project).where(subjects: { site_id: site.id }), start_date, running_total: false, by_distinct_subject: false)
        }
      end
      series << {
        name: 'Overall',
        data: by_month(protocol_deviations(project), start_date, running_total: false, by_distinct_subject: false),
        lineWidth: 3,
        visible: false
      }
      graph[:total] = protocol_deviations(project).count
      graph[:categories] = categories
      graph[:series] = series
      graph[:title] = 'Protocol Deviations'
      graph[:yaxis] = '# Protocol Deviations'
      # graph[:xaxis] = ''
      graph
    end

    def unblinding_events(project)
      design = project.designs.find_by(short_name: 'UNB')
      project.sheets.where(design: design, missing: false).joins(:subject).where(subjects: { deleted: false })
    end

    def unblinding_events_data(project, start_date)
      {
        table: unblinding_events_table(project, start_date),
        graph: unblinding_events_graph(project, start_date)
      }
    end

    def unblinding_events_table(project, start_date)
      objects = unblinding_events(project)
      generic_table(project, start_date, 'Unblinding Events', objects, by_distinct_subject: false)
    end

    def unblinding_events_graph(project, start_date)
      graph = {}
      categories = generate_categories_months(start_date)
      series = []
      project.sites.each do |site|
        series << {
          name: site.short_name,
          data: by_month(unblinding_events(project).where(subjects: { site_id: site.id }), start_date, running_total: false, by_distinct_subject: false)
        }
      end
      series << {
        name: 'Overall',
        data: by_month(unblinding_events(project), start_date, running_total: false, by_distinct_subject: false),
        lineWidth: 3,
        visible: false
      }
      graph[:total] = unblinding_events(project).count
      graph[:categories] = categories
      graph[:series] = series
      graph[:title] = 'Unblinding Events'
      graph[:yaxis] = '# Unblinding Events'
      # graph[:xaxis] = ''
      graph
    end
  end
end
