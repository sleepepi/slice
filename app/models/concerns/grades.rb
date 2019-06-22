# frozen_string_literal: true

module Grades
  extend ActiveSupport::Concern
  def overall_grades
    grades = sites.order_number_and_name.collect do |site|
      subject_events = randomized_subject_events_by_site(site)
      completed = subject_events.sum(:unblinded_responses_count)
      total = subject_events.sum(:unblinded_questions_count)
      percent = total.positive? ? completed * 100 / total : nil
      { number_and_short_name: site.number_and_short_name, completed: completed, total: total, percent: percent }
    end
    grades.sort_by { |h| -h[:percent].to_i }
  end

  def event_grades
    events.where(archived: false).order(:position).collect do |event|
      row = { event: event.name, cells: [] }
      sites.order_number_and_name.each do |site|
        subject_events = randomized_subject_events_by_site(site)
        completed = subject_events.where(event: event).sum(:unblinded_responses_count)
        total = subject_events.where(event: event).sum(:unblinded_questions_count)
        row[:cells] << {
          percent: total.positive? ? completed * 100 / total : nil,
          link: "#{ENV["website_url"]}/projects/#{to_param}/subjects?search=events:#{event.to_param}&site_id=#{site.id}"
        }
      end
      row
    end
  end

  def randomized_subject_events_by_site(site)
    SubjectEvent.joins(:subject).where(
      subjects: {
        id: randomizations.joins(:subject).merge(Subject.current).select(:subject_id),
        site: site
      }
    )
  end
end
