# frozen_string_literal: true

require "pats/core"

module Pats
  # Export grades for each site.
  module Grades
    include Pats::Core

    def grades(project)
      {
        overall: project.overall_grades.sort_by { |h| -h[:percent].to_i },
        events: project.event_grades,
        sites: project.sites.order_number_and_name.collect(&:number_and_short_name)
      }
    end
  end
end
