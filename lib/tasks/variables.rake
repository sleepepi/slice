# frozen_string_literal: true

namespace :variables do
  desc 'Update variable layout'
  task update_layout: :environment do
    invisible_variables = Variable.where(display_name_visibility: 'invisible')
    variable_count = invisible_variables.count
    invisible_variables.update_all(display_name_visibility: 'gone')
    puts "Updated layout for #{variable_count} variable#{'s' if variable_count != 1}."
  end
end
