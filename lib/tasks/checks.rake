# frozen_string_literal: true

namespace :checks do
  desc 'Rerun all checks for all sheets'
  task reset: :environment do
    Check.find_each do |check|
      puts check.name.to_s.colorize(:blue).on_white
      check.reset_checks!
      total_count = check.status_checks.count
      puts "#{format('%5d', total_count)} sheet#{'s' if total_count != 1}"
      passed = check.status_checks.where(failed: false).count
      failed = check.status_checks.where(failed: true).count
      puts format('%5d', passed).colorize(passed > 0 ? :green : nil) + ' passed'
      puts (format('%5d', failed) + " failed\n\n").colorize(failed > 0 ? :red : nil)
    end
  end
end
