# frozen_string_literal: true

require 'pats/core'

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
      tables << demographics_age_table(project, sheets)
      tables << demographics_gender_table(project, sheets)
      tables << demographics_race_table(project, sheets)
      tables << demographics_ethnicity_table(project, sheets)

      { tables: tables, extras: extras(project, sheets) }
    end

    def demographics_age_table(project, sheets)
      table = {}
      header = [['Age', 'Overall'] + project.sites.collect(&:short_name)]
      rows = []
      variable = project.variables.find_by_name 'ciw_age_years'
      variable_id = variable.id
      [['3 or 4 years old', "NULLIF(response, '')::numeric >= 3 and NULLIF(response, '')::numeric < 5"], ['5 or 6 years old', "NULLIF(response, '')::numeric >= 5 and NULLIF(response, '')::numeric < 7"], ['7 years or older', "NULLIF(response, '')::numeric >= 7"], ['Unknown or not reported', "response = '' or response IS NULL"]].each do |label, subquery|
        sheet_scope = SheetVariable.where(variable_id: variable_id).where(subquery).select(:sheet_id)
        total_subjects = count_subjects(sheets.where(id: sheet_scope))
        age_row = [label, total_subjects]
        project.sites.each do |site|
          age_row << count_subjects(sheets.where(id: sheet_scope, subjects: { site_id: site.id }))
        end
        rows << age_row
      end
      table[:header] = header
      table[:footer] = []
      table[:rows] = rows
      table[:title] = 'Demographics - Age by Site'
      table
    end

    def demographics_gender_table(project, sheets)
      table = {}
      header = [['Gender', 'Overall'] + project.sites.collect(&:short_name)]
      rows = []
      variable = project.variables.find_by_name 'ciw_sex'
      variable_id = variable.id
      [['Female', "NULLIF(response, '')::numeric = 2"], ['Male', "NULLIF(response, '')::numeric = 1"], ['Unknown or not reported', "response = '' or response IS NULL"]].each do |label, subquery|
        sheet_scope = SheetVariable.where(variable_id: variable_id).where(subquery).select(:sheet_id)
        total_subjects = count_subjects(sheets.where(id: sheet_scope))
        age_row = [label, total_subjects]
        project.sites.each do |site|
          age_row << count_subjects(sheets.where(id: sheet_scope, subjects: { site_id: site.id }))
        end
        rows << age_row
      end
      table[:header] = header
      table[:footer] = []
      table[:rows] = rows
      table[:title] = 'Demographics - Gender by Site'
      table
    end

    def demographics_race_table(project, sheets)
      table = {}
      header = [['Race', 'Overall'] + project.sites.collect(&:short_name)]
      rows = []
      variable = project.variables.find_by_name 'ciw_race'
      variable_id = variable.id
      [['Black / African American', "NULLIF(value, '')::numeric = 3"], ['Other race', "NULLIF(value, '')::numeric IN (1, 2, 4, 5, 98)"]].each do |label, subquery|
        sheet_scope = Response.where(variable_id: variable_id).where(subquery).select(:sheet_id)
        total_subjects = count_subjects(sheets.where(id: sheet_scope))
        race_row = [label, total_subjects]
        project.sites.each do |site|
          race_row << count_subjects(sheets.where(id: sheet_scope, subjects: { site_id: site.id }))
        end
        rows << race_row
      end
      # ['Unknown or not reported', "value = '' or value IS NULL"]
      inverse_sheet_scope = Response.where(variable_id: variable_id).where("NULLIF(value, '')::numeric IN (1, 2, 3, 4, 5, 98)").select(:sheet_id)
      total_subjects = count_subjects(sheets.where.not(id: inverse_sheet_scope))
      race_row = ['Unknown or not reported', total_subjects]
      project.sites.each do |site|
        race_row << count_subjects(sheets.where.not(id: inverse_sheet_scope).where(subjects: { site_id: site.id }))
      end
      rows << race_row
      table[:header] = header
      table[:footer] = []
      table[:rows] = rows
      table[:title] = 'Demographics - Race by Site'
      table
    end

    def demographics_ethnicity_table(project, sheets)
      table = {}
      header = [['Ethnicity', 'Overall'] + project.sites.collect(&:short_name)]
      rows = []
      variable = project.variables.find_by_name 'ciw_ethnicity'
      variable_id = variable.id
      [['Hispanic or Latino', "NULLIF(response, '')::numeric = 1"], ['Not Hispanic or Latino', "NULLIF(response, '')::numeric = 2"], ['Unknown or not reported', "response = '' or response IS NULL"]].each do |label, subquery|
        sheet_scope = SheetVariable.where(variable_id: variable_id).where(subquery).select(:sheet_id)
        total_subjects = count_subjects(sheets.where(id: sheet_scope))
        age_row = [label, total_subjects]
        project.sites.each do |site|
          age_row << count_subjects(sheets.where(id: sheet_scope, subjects: { site_id: site.id }))
        end
        rows << age_row
      end
      table[:header] = header
      table[:footer] = []
      table[:rows] = rows
      table[:title] = 'Demographics - Ethnicity by Site'
      table
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
