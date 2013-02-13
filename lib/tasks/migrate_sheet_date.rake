# bundle exec rake migrate_sheet_date
# bundle exec rake migrate_sheet_date RAILS_ENV=production

desc "Migrate Sheet Date to a Variable at the top of the design."
task migrate_sheet_date: :environment do
  designs = Design.current

  total_designs = designs.count

  puts "Designs: #{total_designs}"

  designs.each_with_index do |design, index|
    puts "Design: #{"%2d" % (index+1)} of #{total_designs}: # Sheets: #{"%4d" % (design.sheets.size)}  -   #{design.name}"

    project_variables = {}

    variable_name = design.study_date_name_full.gsub(/[^[a-z]\w]/, '_').downcase
    display_name = design.study_date_name_full

    name = if (project_variables[design.project.id.to_s] || []).include?(variable_name)
      variable_name
    elsif design.project.variables.where(name: variable_name).size == 0
      variable_name
    else
      variable_name + "_slice"
    end

    variable = design.project.variables.find_or_create_by_name( name, { display_name: display_name, description: "Created automatically by Slice", variable_type: 'date' })
    variable.update_column :user_id, design.project.user_id unless variable.user

    project_variables[design.project.id.to_s] ||= []
    project_variables[design.project.id.to_s] << variable.name

    puts "                                                             #{variable.name}  #{design.project_id}\n"

    design.options.unshift({ variable_id: variable.id.to_s, branching_logic: "" })
    design.save

    design.sheets.each do |sheet|
      sv = sheet.sheet_variables.find_or_create_by_variable_id( variable.id, { user_id: design.project.user_id } )
      sv.update_attributes sv.format_response('date', sheet.study_date.strftime("%m/%d/%Y"))
    end

  end
end
