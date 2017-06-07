# frozen_string_literal: true

namespace :sheets do
  desc "Check validity of all sheets"
  task check_validity: :environment do
    project_results = []

    begin
      project_slugs = ARGV.find { |key| !(/^PROJECTS=/ =~ key).nil? }

      project_scope = Project.current
      if project_slugs.present?
        project_slugs = project_slugs.gsub(/^PROJECTS=/, "").split(",")
        project_scope = project_scope.where(slug: project_slugs)
      end

      current_sheet = 0
      total_sheets = Sheet.current.where(missing: false).joins(:project).merge(project_scope).joins(:subject).merge(Subject.current).count

      total_projects = project_scope.count
      project_scope.order(:id).find_each.with_index do |project, project_index|
        project_results[project_index] = { name: project.name, param: project.to_param, invalid_sheets_count: 0, valid_sheets_count: 0 }

        total_project_sheets = project.sheets.where(missing: false).count
        project.sheets.where(missing: false).order(:id).find_each.with_index do |sheet, index|
          count_message = " [Sheet #{index + 1} of #{total_project_sheets} (#{format('%0.2f', ((index + 1) * 100.0 / total_project_sheets))}%), Project #{project_index + 1} of #{total_projects}], [All Sheets #{current_sheet + 1} of #{total_sheets} (#{format('%0.2f', ((current_sheet + 1) * 100.0 / total_sheets))}%)]"
          if sheet.successfully_validated?
            print "\r#{format('%6d', sheet.id)}:" + " VALID".colorize(:green) + count_message
            project_results[project_index][:valid_sheets_count] += 1
          else
            in_memory_sheet = Validation::InMemorySheet.new(sheet)
            in_memory_sheet.variables = sheet.design.variables.to_a
            if in_memory_sheet.valid?
              print "\r#{format('%6d', sheet.id)}:" + " VALID".colorize(:green) + count_message
              project_results[project_index][:valid_sheets_count] += 1
              sheet.update_column :successfully_validated, true
            else
              puts "\n#{format('%6d', sheet.id)}:" + " NOT VALID".colorize(:red) + count_message
              puts "        " + "#{ENV['website_url']}/projects/#{sheet.project.to_param}/sheets/#{sheet.to_param}"
              puts "        " + "#{in_memory_sheet.errors.count} error#{'s' unless in_memory_sheet.errors.count == 1}".colorize(:red)
              in_memory_sheet.errors.each do |error|
                puts "       " + " #{error}"
              end
              project_results[project_index][:invalid_sheets_count] += 1
              sheet.update_column :successfully_validated, false
            end
            in_memory_sheet = nil # Alert GC that the variable is no longer needed
          end
          current_sheet += 1
        end
      end
    rescue Interrupt
      puts "\nINTERRUPTED".colorize(:red)
    end

    project_results.sort { |a, b| [b[:invalid_sheets_count], a[:name]] <=> [a[:invalid_sheets_count], b[:name]] }.each do |hash|
      puts "\n"
      puts "#{hash[:name]}".colorize(hash[:invalid_sheets_count] == 0 ? :green : :red) + " #{ENV['website_url']}/projects/#{hash[:param]}"
      puts "  #{hash[:valid_sheets_count]} VALID sheet#{'s' unless hash[:valid_sheets_count] == 1}".colorize(:green) + ", " + "#{hash[:invalid_sheets_count]} NOT VALID sheet#{'s' unless hash[:invalid_sheets_count] == 1}".colorize(hash[:invalid_sheets_count] == 0 ? :white : :red)
    end
  end

  desc "Reset sheet coverage computation"
  task reset_coverage: :environment do
    sheet_count = Sheet.count
    Sheet.where(missing: false).update_all(response_count: nil, total_response_count: nil, percent: nil)
    Sheet.where(missing: true).update_all(response_count: 0, total_response_count: 0, percent: 100)
    SubjectEvent.update_all(
      unblinded_responses_count: nil,
      unblinded_questions_count: nil,
      unblinded_percent: nil,
      blinded_responses_count: nil,
      blinded_questions_count: nil,
      blinded_percent: nil
    )
    puts "Reset coverage for #{sheet_count} sheet#{'s' if sheet_count != 1}."
  end

  desc "Set sheet last edited at if blank"
  task set_last_edited: :environment do
    puts "Last Edited Blank Sheets: #{Sheet.where(last_edited_at: nil).count}"
    Sheet.where(last_edited_at: nil).find_each do |s|
      s.update last_edited_at: s.created_at if s.last_edited_at.nil?
    end
    puts "Last Edited Blank Sheets: #{Sheet.where(last_edited_at: nil).count}"
  end

  desc "Update sheet uploaded files counts"
  task update_uploaded_files_counts: :environment do
    print "Caching sheet uploaded files counts..."
    Sheet.where(uploaded_files_count: nil).find_each(&:update_uploaded_file_counts!)
    puts "DONE"
  end

  desc "Cache sheet comments counts"
  task cache_comments_counts: :environment do
    print "Caching sheet comments counts..."
    Sheet.find_each { |s| Sheet.reset_counters(s.id, :comments) }
    puts "DONE"
  end
end
