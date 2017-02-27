# frozen_string_literal: true

namespace :adverse_events do
  # TODO: Remove in v0.51.0
  desc 'Reset Adverse Event Numbers'
  task reset_numbers: :environment do
    Project.find_each(&:reset_adverse_event_numbers!)
  end
end
