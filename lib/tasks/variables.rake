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

  desc 'Reconfigure variable and stratification factor calculations'
  task update_calculations: :environment do
    Variable.where(variable_type: 'calculated').find_each do |v|
      old_calculation = v.calculation
      v.update calculation: v.readable_calculation
      next if old_calculation == v.calculation
      puts "FROM: #{old_calculation}"
      puts "  TO: #{v.calculation}"
      puts "VERI: #{v.readable_calculation}"
      puts "---"
    end

    StratificationFactor.find_each do |sf|
      old_calculation = sf.calculation
      sf.update calculation: sf.readable_calculation
      next if old_calculation == sf.calculation
      puts "FROM: #{old_calculation}"
      puts "  TO: #{sf.calculation}"
      puts "VERI: #{sf.readable_calculation}"
      puts "---"
    end
  end
end
