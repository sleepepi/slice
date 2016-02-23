# frozen_string_literal: true

namespace :sections do
  desc 'Copy a project to a new blank project'
  task update_level: :environment do
    puts "Sections: #{Section.where(sub_section: false).count}"
    puts "Subsections: #{Section.where(sub_section: true).count}"

    Section.where(sub_section: true).update_all(level: 1)

    puts "\nSections: #{Section.where(level: 0).count}"
    puts "Subsections: #{Section.where(level: 1).count}"
    puts "Warning: #{Section.where(level: 2).count}"
  end
end
