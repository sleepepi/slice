# frozen_string_literal: true

namespace :variables do
  # TODO: Remove in v0.50.0
  desc 'Changes variable type of `time` to `time of day`'
  task change_time_to_time_of_day: :environment do
    Variable.where(variable_type: 'time').update_all(variable_type: 'time_of_day')
  end
end
