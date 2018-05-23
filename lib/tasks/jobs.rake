# frozen_string_literal: true

namespace :jobs do
  desc "Find calculated field errors."
  task calculations_all: :environment do
    ActiveRecord::Base.connection.execute("TRUNCATE sheet_errors RESTART IDENTITY")
    Sheet.update_all(errors_count: 0)

    projects = Project.current
    projects.find_each do |project|
      print "[#{project.id}] #{project.name}"
      designs = project.designs
      designs_count = designs.count
      designs.find_each.with_index do |design, design_index|
        print "\r[#{project.id}] #{project.name} [Design #{design_index + 1} of #{designs_count}]"
        sheets = design.sheets.where(missing: false)
        sheets_count = sheets.count
        design_options = design.design_options.joins(:variable).merge(Variable.where(variable_type: "calculated"))
        design_options_count = design_options.count
        design_options.find_each.with_index do |design_option, design_option_index|
          variable = design_option.variable
          print "\r[#{project.id}] #{project.name} [Design #{design_index + 1} of #{designs_count}] [Variable #{design_option_index + 1} of #{design_options_count}]"
          core_info = "Variable: **#{variable.name}**\n\n`#{variable.readable_calculation}`\n\n`#{variable.calculation}`"
          sheets.find_each.with_index do |sheet, sheet_index|
            next unless sheet.show_design_option?(design_option.branching_logic)
            print "\r[#{project.id}] #{project.name} [Design #{design_index + 1} of #{designs_count}] [Variable #{design_option_index + 1} of #{design_options_count}] [Sheet #{sheet_index + 1} of #{sheets_count}]"
            sheet_info = "\n\n`#{sheet.expanded_calculation(variable.calculation)}`"
            begin
              result = sheet.exec_js_context.eval(sheet.expanded_calculation(variable.calculation))
            rescue ExecJS::RuntimeError, ExecJS::ProgramError
              result = nil
            end
            sheet_info += "\n\nCalculated:\n\n"
            if result.present?
              sheet_info += "**#{result}**"
            else
              sheet_info += "**`null`**"
            end

            sv = sheet.sheet_variables.find_by(variable: variable)
            stored_value = sv&.value

            if variable.calculated_format.present?
              begin
                result = format(variable.calculated_format, result)
                sheet_info += "\n\nFormatted [#{variable.calculated_format}]:\n\n**#{result}**"
              rescue
                sheet_info += "\n\nFormatted [#{variable.calculated_format}]:\n\n==Formatting failed=="
              end

              begin
                stored_value = format(variable.calculated_format, stored_value)
              rescue
                # Nothing
              end
            end

            unless fuzzy_equal?(stored_value.to_f, result.to_f)
              sheet_info += "\n\nStored:\n\n"
              if stored_value.present?
                sheet_info += "==**#{stored_value}**=="
              else
                sheet_info += "==`null`=="
              end
              SheetError.create(project: project, sheet: sheet, description: core_info + sheet_info)
            end
          end
        end
      end
      puts ""
    end
  end
end

# Only compare significant decimal digits.
# Example: 73.99999999999999 == 73.99999999999998
# fuzzy_equal?(73.99999999999999, 74)
# => true
# fuzzy_equal?(73.99999999999999, 73.99999999999998)
# => true
# fuzzy_equal?(73.99999999999999, 73.99999999999989)
# => false
DELTA = 10.0 ** -(Float::DIG - 1)

def fuzzy_equal?(a, b)
  diff = (a - b).abs
  diff <= DELTA
end
