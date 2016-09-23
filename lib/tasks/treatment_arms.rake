# frozen_string_literal: true

namespace :treatment_arms do
  # TODO: Remove in 0.43.0
  desc 'Add short names to existing treatment arms'
  task short_names: :environment do
    TreatmentArm.all.each do |ta|
      next if (/.*\(.*\)/ =~ ta.name).nil?
      short_name = ta.name.split(' (').last.delete(')')
      name = ta.name.gsub(" (#{short_name})", '')
      puts ta.name.colorize(:red)
      puts name.colorize(:green)
      puts "#{short_name}\n".colorize(:green)
      ta.update name: name, short_name: short_name
    end
  end
end
