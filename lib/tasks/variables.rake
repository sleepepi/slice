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

    DesignOption.where.not(design_id: nil).find_each do |option|
      old_branching_logic = option.branching_logic
      option.update branching_logic: option.readable_branching_logic
      next if old_branching_logic == option.branching_logic
      puts "FROM: #{old_branching_logic}"
      puts "  TO: #{option.branching_logic}"
      puts "VERI: #{option.readable_branching_logic}"
      puts "---"
    end
  end

  desc 'Check for incorrect calculations and branching logic'
  task list_broken_calculations_and_branching_logic: :environment do
    variables = \
      Variable.includes(:project).where(variable_type: 'calculated')
              .select { |v| v.calculation.match(/\w+\b(?<!\bnull)(?<!\boverlap)(?<![\d+])/) }
    variables.each do |v|
      puts "#{ENV['website_url']}/projects/#{v.project.to_param}/variables/#{v.to_param}\n#{v.calculation}\n\n"
    end

    options = \
      DesignOption.includes(design: :project).where.not(design_id: nil)
              .select { |opt| opt.branching_logic.match(/\w+\b(?<!\bnull)(?<!\boverlap)(?<![\d+])/) }
    options.each do |opt|
      puts "#{ENV['website_url']}/projects/#{opt.design.project.to_param}/designs/#{opt.design.to_param}/edit\n#{opt.branching_logic}\n\n"
    end

    stratification_factors = \
      StratificationFactor.includes(:project)
              .select { |sf| sf.calculation.match(/\w+\b(?<!\bnull)(?<!\boverlap)(?<![\d+])/) }
    stratification_factors.each do |sf|
      puts "#{ENV['website_url']}/projects/#{sf.project.to_param}/schemes/#{sf.randomization_scheme_id}/stratification_factors/#{sf.id}\n#{sf.calculation}\n\n"
    end

    puts "             Broken Variable Calculations: #{variables.count}"
    puts "               Broken Option Calculations: #{options.count}"
    puts "Broken Stratification Factor Calculations: #{stratification_factors.count}"
  end
end
