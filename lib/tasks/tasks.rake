# frozen_string_literal: true

namespace :tasks do
  desc "Rerun all checks for all sheets"
  task update_dates: :environment do
    project = Project.find_by(slug: "pats")
    puts project.name

    project.randomizations.each do |randomization|
      base_date = randomization.randomized_at.to_date
      puts base_date
      randomization.tasks.each do |task|
        rst = randomization.randomization_scheme.randomization_scheme_tasks.find_by(description: task.description)
        if rst
          puts "#{task.due_date}  |  #{rst.due_date(base_date)}" if task.due_date != rst.due_date(base_date)
          puts "#{task.window_start_date}  |  #{rst.window_start_date(base_date)}" if task.window_start_date != rst.window_start_date(base_date)
          puts "#{task.window_end_date}  |  #{rst.window_end_date(base_date)}" if task.window_end_date != rst.window_end_date(base_date)

          task.update(
            due_date: rst.due_date(base_date),
            window_start_date: rst.window_start_date(base_date),
            window_end_date: rst.window_end_date(base_date)
          )
        else
          puts "Template #{"NOT FOUND".red} for Task: #{task.id}"
        end
      end
    end
  end
end
