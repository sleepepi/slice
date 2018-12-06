# frozen_string_literal: true

# Generates status badge for AE review team assignments.
module AssignmentsHelper
  def status_badge(assignment)
    if assignment.completed?
      content_tag(:span, class: "badge badge-light") do
        icon("fas", "check") + " Complete"
      end
    elsif assignment.overdue?
      content_tag(:span, class: "badge badge-danger") do
        icon("fas", "exclamation-triangle") + " Overdue"
      end
    else
      content_tag(:span, class: "badge badge-primary") do
        icon("fas", "user-clock") + " Assigned"
      end
    end
  end
end
