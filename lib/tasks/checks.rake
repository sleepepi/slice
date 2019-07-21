# frozen_string_literal: true

namespace :checks do
  desc "Rerun all checks for all sheets"
  task run_console: :environment do
    start_time = Time.zone.now

    Check.runnable.find_each do |check|
      puts check.name.blue.bg_gray
      if check.last_run_at && check.last_run_at > Time.zone.now - 1.hour
        puts "       skipped (run recently)\n\n"
        next
      end

      t = Time.zone.now
      check.run!
      failed = check.status_checks.where(failed: true).count
      puts format("%6d failed", failed).send(failed.positive? ? :red : :colorless)
      puts "#{format("%6d", Time.zone.now - t)} seconds\n\n"
    end

    puts "#{format("%6d", Time.zone.now - start_time)} seconds (total)\n\n"
  end

  desc "Use to run checks from a cron job on a scheduled basis."
  task run_job: :environment do
  unless ENV["JOB_SERVER"] == "true"
    puts "SKIP: Not running on job server."
    next
  end

    Check.runnable.where("last_run_at < ? OR last_run_at IS NULL", Time.zone.now - 1.hour).find_each(&:run!)
  end

  desc "Truncate all existing status_checks"
  task truncate_status_checks: :environment do
    ActiveRecord::Base.connection.execute("TRUNCATE status_checks RESTART IDENTITY")
    Check.update_all last_run_at: nil
  end
end
