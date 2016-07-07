# frozen_string_literal: true

require 'pats/core'

module Pats
  # Exports demographics statistics for subjects on PATS.
  module Demographics
    include Pats::Core

    def demographics(project, start_date)
      table = {}
      header = []
      header_row = ['Characteristic', 'Overall'] + project.sites.collect(&:short_name)
      header << header_row
      rows = []
      # Age
      rows << ['Age', ''] + [''] * project.sites.count
      variable = project.variables.find_by_name 'ciw_age_years'
      variable_id = variable.id
      [['3 or 4 years old', "NULLIF(response, '')::numeric >= 3 and NULLIF(response, '')::numeric < 5"], ['5 or 6 years old', "NULLIF(response, '')::numeric >= 5 and NULLIF(response, '')::numeric < 7"], ['7 years or older', "NULLIF(response, '')::numeric >= 7"], ['Unknown or not reported', "response = '' or response IS NULL"]].each do |label, subquery|
        sheet_scope = SheetVariable.where(variable_id: variable_id).where(subquery).select(:sheet_id)
        total_age = count_subjects(ciws(project).where(id: sheet_scope))
        age_row = [label, total_age]
        project.sites.each do |site|
          age_row << count_subjects(ciws(project).where(id: sheet_scope, subjects: { site_id: site.id }))
        end
        rows << age_row
      end

      # Gender
      rows << ['Gender', ''] + [''] * project.sites.count
      variable = project.variables.find_by_name 'ciw_sex'
      variable_id = variable.id
      [['Female', "NULLIF(response, '')::numeric = 2"], ['Male', "NULLIF(response, '')::numeric = 1"], ['Unknown or not reported', "response = '' or response IS NULL"]].each do |label, subquery|
        sheet_scope = SheetVariable.where(variable_id: variable_id).where(subquery).select(:sheet_id)
        total_age = count_subjects(ciws(project).where(id: sheet_scope))
        age_row = [label, total_age]
        project.sites.each do |site|
          age_row << count_subjects(ciws(project).where(id: sheet_scope, subjects: { site_id: site.id }))
        end
        rows << age_row
      end

      # Race
      rows << ['Race', ''] + [''] * project.sites.count
      variable = project.variables.find_by_name 'ciw_race'
      variable_id = variable.id
      [['American Indian / Native Alaskan', "NULLIF(value, '')::numeric = 1"], ['Asian', "NULLIF(value, '')::numeric = 2"], ['Black / African American', "NULLIF(value, '')::numeric = 3"], ['Native Hawaiian / Other Pacific Islander', "NULLIF(value, '')::numeric = 4"], ['White / Caucasian', "NULLIF(value, '')::numeric = 5"], ['Other race', "NULLIF(value, '')::numeric = 98"], ['Unknown or not reported', "value = '' or value IS NULL"]].each do |label, subquery|
        sheet_scope = Response.where(variable_id: variable_id).where(subquery).select(:sheet_id)
        total_age = count_subjects(ciws(project).where(id: sheet_scope))
        age_row = [label, total_age]
        project.sites.each do |site|
          age_row << count_subjects(ciws(project).where(id: sheet_scope, subjects: { site_id: site.id }))
        end
        rows << age_row
      end

      # Ethnicity
      rows << ['Ethnicity', ''] + [''] * project.sites.count
      variable = project.variables.find_by_name 'ciw_ethnicity'
      variable_id = variable.id
      [['Hispanic or Latino', "NULLIF(response, '')::numeric = 1"], ['Not Hispanic or Latino', "NULLIF(response, '')::numeric = 2"], ['Unknown or not reported', "response = '' or response IS NULL"]].each do |label, subquery|
        sheet_scope = SheetVariable.where(variable_id: variable_id).where(subquery).select(:sheet_id)
        total_age = count_subjects(ciws(project).where(id: sheet_scope))
        age_row = [label, total_age]
        project.sites.each do |site|
          age_row << count_subjects(ciws(project).where(id: sheet_scope, subjects: { site_id: site.id }))
        end
        rows << age_row
      end

      table[:header] = header
      table[:footer] = []
      table[:rows] = rows
      table[:title] = 'Demographic and baseline characteristics - Categorical measures'
      { table: table }
    end
  end
end
