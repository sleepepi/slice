# frozen_string_literal: true

namespace :variables do
  desc "Check for incorrect calculations and branching logic"
  task list_broken_calculations_and_branching_logic: :environment do
    variables = \
      Variable.includes(:project).where(variable_type: "calculated")
              .select { |v| v.calculation.to_s.match(/\w+\b(?<!\bnull)(?<!\boverlap)(?<![\d+])/) }
    variables.each do |v|
      puts "#{ENV['website_url']}/projects/#{v.project.to_param}/variables/#{v.to_param}\n#{v.calculation}\n\n"
    end

    options = \
      DesignOption.includes(design: :project).where.not(design_id: nil)
                  .select { |opt| opt.branching_logic.to_s.match(/\w+\b(?<!\bnull)(?<!\boverlap)(?<![\d+])/) }
    options.each do |opt|
      puts "#{ENV['website_url']}/projects/#{opt.design.project.to_param}/designs/"\
        "#{opt.design.to_param}/edit\n#{opt.branching_logic}\n\n"
    end

    stratification_factors = \
      StratificationFactor.includes(:project)
                          .select { |sf| sf.calculation.to_s.match(/\w+\b(?<!\bnull)(?<!\boverlap)(?<![\d+])/) }
    stratification_factors.each do |sf|
      puts "#{ENV['website_url']}/projects/#{sf.project.to_param}/schemes/"\
        "#{sf.randomization_scheme_id}/stratification_factors/#{sf.id}\n#{sf.calculation}\n\n"
    end

    puts "             Broken Variable Calculations: #{variables.count}"
    puts "               Broken Option Calculations: #{options.count}"
    puts "Broken Stratification Factor Calculations: #{stratification_factors.count}"
  end
end
