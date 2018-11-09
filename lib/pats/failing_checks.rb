# frozen_string_literal: true

require "pats/core"

module Pats
  # Export number of failing checks for each site.
  module FailingChecks
    include Pats::Core

    def failing_checks(project)
      {
        checks: checks_table(project).sort_by { |hash| [-hash[:total][:count], hash[:check]] },
        totals: check_totals(project)
      }
    end

    def check_totals(project)
      project.sites.collect do |site|
        total = StatusCheck.where(failed: true).joins(:check, sheet: :subject).merge(project.checks.runnable).merge(Subject.current.where(site: site)).count
        { short_name: site.short_name, count: total, link: "#{ENV["website_url"]}/projects/#{project.to_param}/sheets?search=checks:present&site_id=#{site.id}" }
      end
    end

    def checks_table(project)
      project.checks.runnable.order(:name).collect do |check|
        row = { check: check.name, cells: [] }
        row_count = 0
        project.sites.each do |site|
          count = check.status_checks.where(failed: true).joins(sheet: :subject).merge(Subject.current.where(site: site)).count
          row_count += count
          row[:cells] << {
            count: count,
            link: "#{ENV["website_url"]}/projects/#{project.to_param}/sheets?search=checks:#{check.to_param}&site_id=#{site.id}"
          }
        end
        row[:total] = { count: row_count, link: "#{ENV["website_url"]}/projects/#{project.to_param}/sheets?search=checks:#{check.to_param}" }
        row
      end
    end
  end
end
