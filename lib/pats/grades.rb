# frozen_string_literal: true

require 'pats/core'

module Pats
  # Export grades for each site.
  module Grades
    include Pats::Core

    def grades(project)
      {
        overall: overall_grades(project).sort_by { |h| -h[:percent].to_i },
        events: event_grades(project),
        sites: project.sites.collect(&:short_name)
      }
    end

    def overall_grades(project)
      project.sites.collect do |site|
        subject_events = randomized_subject_events_by_site(project, site)
        completed = subject_events.sum(:unblinded_responses_count)
        total = subject_events.sum(:unblinded_questions_count)
        percent = compute_percent(completed, total)
        { short_name: site.short_name, completed: completed, total: total, percent: percent }
      end
    end

    def event_grades(project)
      project.events.where(archived: false).order(:position).collect do |event|
        row = { event: event.name, cells: [] }
        project.sites.each do |site|
          subject_events = randomized_subject_events_by_site(project, site)
          completed = subject_events.where(event: event).sum(:unblinded_responses_count)
          total = subject_events.where(event: event).sum(:unblinded_questions_count)
          row[:cells] << {
            percent: compute_percent(completed, total),
            link: "#{ENV['website_url']}/projects/#{project.to_param}/subjects?search=events:#{event.to_param}&site_id=#{site.id}"
          }
        end
        row
      end
    end

    def randomized_subject_events_by_site(project, site)
      SubjectEvent.joins(:subject).where(subjects: { id: randomizations(project).select(:subject_id), site: site })
    end

    def compute_percent(completed, total)
      total.positive? ? completed * 100 / total : nil
    end
  end
end
