# frozen_string_literal: true

namespace :variables do
  desc 'Update variable layout'
  task update_layout: :environment do
    invisible_variables = Variable.where(display_name_visibility: 'invisible')
    variable_count = invisible_variables.count
    invisible_variables.update_all(display_name_visibility: 'gone')
    puts "Updated layout for #{variable_count} variable#{'s' if variable_count != 1}."
  end

  desc 'Changes variable type of `time` to `time of day`'
  task change_time_to_time_of_day: :environment do
    Variable.where(variable_type: 'time').update_all(variable_type: 'time_of_day')
  end
end
