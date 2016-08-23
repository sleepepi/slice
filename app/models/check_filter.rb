# frozen_string_literal: true

# Allows project editors to identify and filter subset populations for checks.
class CheckFilter < ApplicationRecord
  # Constants
  OPERATOR_TYPE = [
    ['Equal', 'eq'],
    ['Not Equal', 'ne'],
    ['Less Than', 'lt'],
    ['Greater Than', 'gt'],
    ['Less Than or Equal', 'le'],
    ['Greater Than or Equal', 'ge']
  ]

  FILTER_TYPE = [
    ['Variable', 'variable'],
    ['Randomized', 'randomized']
  ]

  # Model Validation
  validates :project_id, :user_id, :check_id, :operator, :filter_type,
            presence: true
  validates :operator, inclusion: { in: OPERATOR_TYPE.collect(&:second) }
  validates :filter_type, inclusion: { in: FILTER_TYPE.collect(&:second) }

  # Model Relationships
  belongs_to :project
  belongs_to :user
  belongs_to :check
  belongs_to :variable, optional: true
  has_many :check_filter_values

  # Model Methods
  def name
    if variable
      variable.name
    elsif filter_type == 'randomized' && operator == 'eq'
      'randomized'
    elsif filter_type == 'randomized' && operator == 'ne'
      'unrandomized'
    else
      filter_type
    end
  end

  def name_was
    if variable
      variable.name
    elsif filter_type_was == 'randomized' && operator_was == 'eq'
      'randomized'
    elsif filter_type_was == 'randomized' && operator_was == 'ne'
      'unrandomized'
    else
      filter_type_was
    end
  end

  def operator_name
    OPERATOR_TYPE.find { |_name, value| value == operator }.first
  end

  def destroy
    check_filter_values.destroy_all
    super
  end

  def compute(current_user)
    if variable
      compute_for_variable(current_user)
    elsif filter_type == 'randomized'
      randomized_subjects_sheets(current_user)
    else
      Sheet.none
    end
  end

  def randomized_subjects_sheets(current_user)
    sheet_scope = current_user.all_viewable_sheets.where(project: project)
    sheet_scope = if operator == 'eq'
                    sheet_scope.where(subject_id: project.subjects.randomized.select(:id))
                  elsif operator == 'ne'
                    sheet_scope.where(subject_id: project.subjects.unrandomized.select(:id))
                  else
                    Sheet.none
                  end
    sheet_scope
  end

  def compute_for_variable(current_user)
    inverse = (operator == 'ne')

    subquery_values = check_filter_values.distinct.pluck(:value)

    sheet_scope = current_user.all_viewable_sheets.where(project: project)
    return Sheet.none if operator.in?(%w(lt gt le ge))
    return sheet_scope if subquery_values.count == 0

    if variable.variable_type == 'checkbox'
      scope = Response
      if all_numeric?
        subquery = "NULLIF(value, '')::numeric IN (#{subquery_values.sort.join(', ')})"
      else
        subquery = "NULLIF(value, '')::text IN (#{subquery_values.collect { |v| "'#{v}'" }.sort.join(', ')})"
      end
    else
      scope = SheetVariable
      if all_numeric?
        subquery = "NULLIF(response, '')::numeric IN (#{subquery_values.sort.join(', ')})"
      else
        subquery = "NULLIF(response, '')::text IN (#{subquery_values.collect { |v| "'#{v}'" }.sort.join(', ')})"
      end
    end

    select_sheet_ids = scope.where(variable: variable).where(subquery).select(:sheet_id)

    sheet_scope = if inverse
                    sheet_scope.where.not(id: select_sheet_ids)
                  else
                    sheet_scope.where(id: select_sheet_ids)
                  end
    sheet_scope
  end

  def all_numeric?
    check_filter_values.distinct.pluck(:value).count { |v| !(v =~ /^[-+]?[0-9]+$/) } == 0
  end
end
