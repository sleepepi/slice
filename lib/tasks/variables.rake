# frozen_string_literal: true

namespace :variables do
  desc 'Update variable layout'
  task update_layout: :environment do
    invisible_variables = Variable.where(display_name_visibility: 'invisible')
    variable_count = invisible_variables.count
    invisible_variables.update_all(display_name_visibility: 'gone')
    puts "Updated layout for #{variable_count} variable#{'s' if variable_count != 1}."
  end

  desc 'Migrate Time of Day Variables'
  task migrate_time_of_day: :environment do
    include DateAndTimeParser

    sheet_variables = SheetVariable.where(variable_id: Variable.current.where(variable_type: 'time').select(:id))
    object_count = sheet_variables.count
    sheet_variables.find_each.with_index do |object, index|
      print "\r#{index + 1} of #{object_count} #{format('%0.2f%', (index + 1) * 100.0 / object_count)} "
      object.update response: change_response_to_seconds(object.response)
    end
    grids = Grid.where(variable_id: Variable.current.where(variable_type: 'time').select(:id))
    object_count = grids.count
    grids.find_each.with_index do |object, index|
      print "\r#{index + 1} of #{object_count} #{format('%0.2f%', (index + 1) * 100.0 / object_count)} "
      object.update response: change_response_to_seconds(object.response)
    end
    puts "\nMigration of Time of Day Variables Complete"
  end
end

def change_response_to_seconds(time_string)
  time_of_day = parse_time_deprecated(time_string)
  if time_of_day
    seconds_since_midnight = time_of_day.hour * 3600 + time_of_day.min * 60 + time_of_day.sec
  else
    seconds_since_midnight = nil
  end
  new_time_of_day = parse_time_of_day_from_hash_to_s(parse_time_of_day(seconds_since_midnight))

  if time_string.present? && new_time_of_day.present?
    print 'Changes from '.colorize(:white) + time_string.to_s.colorize(:red) +
      ' to '.colorize(:white) + new_time_of_day.to_s.colorize(:green)
  end
  new_time_of_day
end
