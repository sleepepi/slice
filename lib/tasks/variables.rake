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

  desc 'Migrate grid variables'
  task migrate_grid_variables: :environment do
    # ActiveRecord::Base.connection.execute('TRUNCATE grid_variables RESTART IDENTITY;')
    Variable.where(variable_type: 'grid').find_each do |variable|
      variable.deprecated_grid_variables.each_with_index do |deprecated_grid_variable_hash, index|
        variable.child_grid_variables.create(
          project_id: variable.project_id,
          child_variable_id: deprecated_grid_variable_hash[:variable_id],
          position: index
        )
      end
      puts "#{variable.child_variables.count == 1 ? " 1 child   " : "#{format('%2d', variable.child_variables.count)} children"} added to #{variable.name}"
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
