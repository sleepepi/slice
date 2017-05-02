# frozen_string_literal: true

namespace :variables do
  # TODO: Remove in v0.53.0
  desc 'Separate variable calculation formats from time of day formats.'
  task populate_time_of_day_format: :environment do
    Variable.where(variable_type: 'time_of_day').find_each do |variable|
      variable.update time_of_day_format: variable.format if variable.format.present?
    end
  end

  desc 'Fix default time duration format'
  task update_time_duration_format: :environment do
    Variable.where(time_duration_format: '').update_all(time_duration_format: 'hh:mm:ss')
  end
end
