# frozen_string_literal: true

namespace :domains do
  desc "Finds and links missing values for numerics, integers, and calculated variables."
  task link_missing_values: :environment do
    variables = Variable.current.joins(:domain).where(
      variable_type: %w(numeric integer calculated)
    ).order(:id)
    variables_count = variables.count
    total_objects_count = 0
    variables.includes(:project, domain: :domain_options).each_with_index do |variable, index|
      puts "#{variable.name.white} #{index * 100 / variables_count}%"
      slicer = Slicers.for(variable)

      variable.domain.domain_options.each do |option|
        puts "#{option.value.white} #{option.name}"
        value = option.value.gsub(/\.0$/, "")

        params = slicer.format_for_db_update(value)

        svs = SheetVariable.where(variable: variable, value: [value, "#{value}.0"])
        total_objects_count += fix_value_to_domain_option(svs, params)
        gds = Grid.where(variable: variable, value: [value, "#{value}.0"])
        total_objects_count += fix_value_to_domain_option(gds, params)
        rsps = Response.where(variable: variable, value: [value, "#{value}.0"])
        total_objects_count += fix_value_to_domain_option(rsps, params)
      end
      puts "\n\n"
    end
    puts "Total Objects updated: #{total_objects_count}"
  end
end

def fix_value_to_domain_option(objects, params)
  count = objects.count
  if objects.present?
    puts "Objects: #{objects.count}".green.bg_black
    objects.update_all params
  end
  count
end
