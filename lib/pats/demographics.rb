# frozen_string_literal: true

require 'pats/core'
require 'pats/characteristics'

module Pats
  # Exports demographics statistics for subjects on PATS.
  module Demographics
    include Pats::Core

    def demographics_screened(project)
      demographics(project, screened_sheets(project))
    end

    def demographics_consented(project)
      demographics(project, consented_sheets(project))
    end

    def demographics_eligible(project)
      demographics(project, eligible_sheets(project))
    end

    def demographics_randomized(project)
      demographics(project, randomized_sheets(project))
    end

    def female_sheets(project, sheets)
      variable = project.variables.find_by_name 'ciw_sex'
      variable_id = variable.id
      subquery = "NULLIF(response, '')::numeric = 2"
      sheet_scope = SheetVariable.where(variable_id: variable_id).where(subquery).select(:sheet_id)
      sheets.where(id: sheet_scope)
    end

    def male_sheets(project, sheets)
      variable = project.variables.find_by_name 'ciw_sex'
      variable_id = variable.id
      subquery = "NULLIF(response, '')::numeric = 1"
      sheet_scope = SheetVariable.where(variable_id: variable_id).where(subquery).select(:sheet_id)
      sheets.where(id: sheet_scope)
    end

    def black_race_sheets(project, sheets)
      variable = project.variables.find_by_name 'ciw_race'
      variable_id = variable.id
      subquery = "NULLIF(value, '')::numeric = 3"
      sheet_scope = Response.where(variable_id: variable_id).where(subquery).select(:sheet_id)
      sheets.where(id: sheet_scope)
    end

    def other_race_sheets(project, sheets)
      variable = project.variables.find_by_name 'ciw_race'
      variable_id = variable.id
      subquery = "NULLIF(value, '')::numeric IN (1, 2, 4, 5, 98)"
      sheet_scope = Response.where(variable_id: variable_id).where(subquery).select(:sheet_id)
      sheets.where(id: sheet_scope)
    end

    def age_3_to_4_sheets(project, sheets)
      variable = project.variables.find_by_name 'ciw_age_years'
      variable_id = variable.id
      subquery = "NULLIF(response, '')::numeric >= 3 and NULLIF(response, '')::numeric < 5"
      sheet_scope = SheetVariable.where(variable_id: variable_id).where(subquery).select(:sheet_id)
      sheets.where(id: sheet_scope)
    end

    def age_5_to_6_sheets(project, sheets)
      variable = project.variables.find_by_name 'ciw_age_years'
      variable_id = variable.id
      subquery = "NULLIF(response, '')::numeric >= 5 and NULLIF(response, '')::numeric < 7"
      sheet_scope = SheetVariable.where(variable_id: variable_id).where(subquery).select(:sheet_id)
      sheets.where(id: sheet_scope)
    end

    def age_7_plus_sheets(project, sheets)
      variable = project.variables.find_by_name 'ciw_age_years'
      variable_id = variable.id
      subquery = "NULLIF(response, '')::numeric >= 7"
      sheet_scope = SheetVariable.where(variable_id: variable_id).where(subquery).select(:sheet_id)
      sheets.where(id: sheet_scope)
    end

    def demographics(project, sheets)
      tables = []
      ['age', 'gender', 'race', 'ethnicity'].each do |characteristic_type|
        tables << demographics_table(project, sheets, characteristic_type)
      end
      { tables: tables, extras: extras(project, sheets) }
    end

    def demographics_table(project, sheets, characteristic_type)
      characteristic = Pats::Characteristics.for(characteristic_type, project)
      rows = characteristic.categories.collect do |category|
        compute_row(sheets, characteristic, category)
      end
      build_table(characteristic, rows)
    end

    def build_table(characteristic, rows)
      table = {}
      table[:header] = compute_header(characteristic)
      table[:footer] = []
      table[:rows] = rows
      table[:title] = compute_title(characteristic)
      table
    end

    def compute_title(characteristic)
      "Demographics - #{characteristic.label} by Site"
    end

    def compute_header(characteristic)
      header = []
      header << ['', { text: 'Overall', colspan: 2 }] + characteristic.project.sites.collect { |s| { text: s.short_name, colspan: 2 } }
      header << [characteristic.label, { text: 'N', class: 'count' }, { text: '%', class: 'percent' }] + [{ text: 'N', class: 'count' }, { text: '%', class: 'percent' }] * characteristic.project.sites.count
      header
    end

    def compute_row(sheets, characteristic, category)
      label = category[:label]
      subquery = category[:subquery]
      css_class = category[:css_class]
      inverse = category[:inverse]

      variable = characteristic.variable
      project = characteristic.project
      model = if variable.variable_type == 'checkbox'
                Response
              else
                SheetVariable
              end
      sheet_scope = model.where(variable: variable).where(subquery).select(:sheet_id)
      total_subjects = if inverse
                         count_subjects(sheets.where.not(id: sheet_scope))
                       else
                         count_subjects(sheets.where(id: sheet_scope))
                       end
      total_percent = "#{(total_subjects * 100 / sheets.count rescue 0)} %"
      row = [{ value: label, class: css_class }, { value: total_subjects, class: [css_class, 'count'] }, { value: total_percent, class: [css_class, 'percent'] }]
      project.sites.each do |site|
        site_subject_count = count_subjects(sheets.where(subjects: { site_id: site.id }))
        subject_count = if inverse
                          count_subjects(sheets.where.not(id: sheet_scope).where(subjects: { site_id: site.id }))
                        else
                          count_subjects(sheets.where(id: sheet_scope).where(subjects: { site_id: site.id }))
                        end
        row << { value: subject_count, class: [css_class, 'count'].compact }
        row << { value: "#{(subject_count * 100 / site_subject_count rescue 0)} %", class: [css_class, 'percent'].compact }
      end
      row
    end

    def extras(project, sheets)
      extras = { females: {}, males: {} }
      extras[:females][:total] = female_sheets(project, sheets).count
      extras[:females][:black] = black_race_sheets(project, female_sheets(project, sheets)).count
      extras[:females][:other] = other_race_sheets(project, female_sheets(project, sheets)).count
      extras[:males][:total] = male_sheets(project, sheets).count
      extras[:males][:black] = black_race_sheets(project, male_sheets(project, sheets)).count
      extras[:males][:other] = other_race_sheets(project, male_sheets(project, sheets)).count
      extras[:females][:age3to4] = age_3_to_4_sheets(project, female_sheets(project, sheets)).count
      extras[:females][:age5to6] = age_5_to_6_sheets(project, female_sheets(project, sheets)).count
      extras[:females][:age7plus] = age_7_plus_sheets(project, female_sheets(project, sheets)).count
      extras[:males][:age3to4] = age_3_to_4_sheets(project, male_sheets(project, sheets)).count
      extras[:males][:age5to6] = age_5_to_6_sheets(project, male_sheets(project, sheets)).count
      extras[:males][:age7plus] = age_7_plus_sheets(project, male_sheets(project, sheets)).count
      extras
    end
  end
end
