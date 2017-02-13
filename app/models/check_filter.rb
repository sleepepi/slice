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
    ['Greater Than or Equal', 'ge'],
    ['Missing', 'missing']
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
  belongs_to :check, touch: true
  belongs_to :variable, optional: true
  has_many :check_filter_values, -> { order(:value) }

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

  def sheets
    if variable
      compute_sheets_for_variable
    elsif filter_type == 'randomized'
      randomized_subjects_sheets
    else
      Sheet.none
    end
  end

  def randomized_subjects_sheets
    Sheet.none
  end

  def randomized_subjects
    subject_scope = project.subjects
    if operator == 'eq'
      subject_scope.where(id: project.subjects.randomized.select(:id))
    elsif operator == 'ne'
      subject_scope.where(id: project.subjects.unrandomized.select(:id))
    else
      Subject.none
    end
  end

  def compute_sheets_for_variable
    sheet_scope = project.sheets
    return sheet_scope if subquery_values.count == 0
    select_sheet_ids = subquery_scope.where(variable: variable).left_outer_joins(:domain_option).where(subquery).select(:sheet_id)
    if operator == 'missing'
      subjects = project.subjects.where(id: sheet_scope.where(id: select_sheet_ids).select(:subject_id))
      sheet_scope.where.not(subject_id: subjects.select(:id))
    else
      sheet_scope.where(id: select_sheet_ids)
    end
  end

  def all_numeric?
    (variable.captured_values + check_filter_values.pluck(:value)).uniq.count { |v| (v =~ /^[-+]?[0-9]*\.?[0-9]*$/).nil? } == 0
  end

  def subquery_attribute
    case variable.variable_type
    when 'file'
      "#{subquery_scope.table_name}.response_file"
    else
      "#{subquery_scope.table_name}.value"
    end
  end

  def subquery_scope
    variable.variable_type == 'checkbox' ? Response : SheetVariable
  end

  def subquery_values
    check_filter_values.distinct.pluck(:value)
  end

  def subjects
    if variable
      compute_subjects_for_variable
    elsif filter_type == 'randomized'
      randomized_subjects
    else
      Subject.none
    end
  end

  def compute_subjects_for_variable
    project.subjects.where(id: sheets.select(:subject_id))
  end

  def subquery
    type_cast = all_numeric? ? 'numeric' : 'text'

    if operator.in?(%w(lt gt le ge))
      full_expression = []
      subquery_values.each do |subquery_value|
        value = all_numeric? ? subquery_value : "'#{subquery_value}'"
        full_expression << "#{domain_option_value_or_attribute(type_cast)} #{database_operator} #{value}"
      end
      full_expression.join(' or ')
    else
      extra = ''
      extra = " or #{domain_option_value_or_attribute(type_cast)} IS NULL" if operator == 'ne'
      "#{domain_option_value_or_attribute(type_cast)} #{database_operator} (#{subquery_values_joined})#{extra}"
    end
  end

  def domain_option_value_or_attribute(type_cast)
    field_one = "NULLIF(domain_options.value, '')::#{type_cast}"
    field_two = "NULLIF(#{subquery_attribute}, '')::#{type_cast}"
    "(CASE WHEN (#{field_one} IS NULL) THEN #{field_two} ELSE #{field_one} END)"
  end

  def database_operator
    case operator
    when 'lt'
      '<'
    when 'gt'
      '>'
    when 'le'
      '<='
    when 'ge'
      '>='
    when 'ne'
      'NOT IN'
    when 'missing'
      'IN'
    else
      'IN'
    end
  end

  def subquery_values_joined
    if all_numeric?
      subquery_values.sort.join(', ')
    else
      subquery_values.collect { |v| "'#{v}'" }.sort.join(', ')
    end
  end
end
