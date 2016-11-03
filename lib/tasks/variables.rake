# frozen_string_literal: true

# TODO: Remove in v0.46.0
namespace :variables do
  desc 'Migrate Time Duration Variables'
  task migrate_time_duration: :environment do
    include DateAndTimeParser

    sheet_variables = SheetVariable.where(variable_id: Variable.current.where(variable_type: 'time_duration').select(:id))
    grids = Grid.where(variable_id: Variable.current.where(variable_type: 'time_duration').select(:id))
    objects = sheet_variables.to_a + grids.to_a

    objects.each do |object|
      object.update response: change_response_to_seconds(object.response)
    end
  end
end

def change_response_to_seconds(time_duration)
  time_duration_hash = parse_time_duration_deprecated(time_duration)
  new_time_duration = parse_time_duration_from_hash_to_s(time_duration_hash)

  if time_duration.present? && new_time_duration.present?
    puts 'Changes from '.colorize(:white) + time_duration.to_s.colorize(:red) +
      ' to '.colorize(:white) + new_time_duration.to_s.colorize(:green)
  end
  new_time_duration
end
# END: TODO
