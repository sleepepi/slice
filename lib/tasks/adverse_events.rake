# frozen_string_literal: true

# TODO: Remove in v65
namespace :adverse_events do
  desc "Rerun all checks for all sheets"
  task renumber: :environment do
    Project.find_each do |project|
      reset_adverse_event_numbers!(project)
    end
  end
end

def reset_adverse_event_numbers!(project)
  AdverseEvent.where(project: project).update_all(number: nil)
  AdverseEvent.where(project: project).order(:created_at).each_with_index do |adverse_event, index|
    adverse_event.update number: index + 1
  end
end
# END TODO
