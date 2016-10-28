# frozen_string_literal: true

# Allows searching of sheets by variable.
class Search
  def self.run_sheets(project, current_user, sheet_scope, token)
    new(project, current_user, sheet_scope, token).run_sheets
  end

  attr_accessor :project, :sheet_scope, :token, :current_user, :variable

  def initialize(project, current_user, sheet_scope, token)
    @project = project
    @current_user = current_user
    @sheet_scope = sheet_scope
    @token = token
    @operator = token[:operator]

    set_checks_or_variable
  end

  def set_checks_or_variable
    case token[:key]
    when 'checks'
      set_checks
    when 'comments', 'comment'
      @comments = true
    when 'aes', 'ae', 'adverse-events', 'adverse-events'
      @aes = true
    when 'files', 'file'
      @files = true
    else
      set_variable
    end
  end

  def set_checks
    if @operator == 'any'
      @checks = @project.runnable_checks
    else
      @checks = @project.checks.where(slug: token[:value].to_s.split(','))
    end
  end

  def set_variable
    @variable = @project.variables.find_by_name(token[:key])
    if %w(any missing).include?(@operator)
      @values = []
      @values = \
        if all_numeric?
          (@variable.captured_values.collect(&:to_f).uniq - @variable.missing_codes.collect(&:to_f)).collect(&:to_s)
        else
          @variable.captured_values.uniq - @variable.missing_codes
        end
    elsif %w(entered present unentered blank).include?(@operator)
      @values = @variable.captured_values.uniq
    else
      @values = token[:value].to_s.split(',').reject(&:blank?).collect(&:strip).reject(&:blank?).uniq
    end
  end

  def run_sheets
    @sheet_scope.where(id: sheets.select(:id))
  end

  def sheets
    if @aes
      all_viewable_sheets.where.not(adverse_event_id: nil)
    elsif @comments
      all_viewable_sheets.where(id: Comment.current.select(:sheet_id))
    elsif @files
      all_viewable_sheets
        .where(id: SheetVariable.with_files.select(:sheet_id))
        .or(all_viewable_sheets.where(id: Grid.with_files.joins(:sheet_variable).select('sheet_variables.sheet_id')))
    elsif @checks
      compute_sheets_for_checks
    elsif @variable
      compute_sheets_for_variable
    elsif @token[:key] == 'randomized'
      randomized_subjects_sheets
    else
      Sheet.none
    end
  end

  def randomized_subjects_sheets
    @project.sheets.where(subject_id: randomized_subjects.select(:id))
  end

  def randomized_subjects
    subject_scope = @current_user.all_viewable_subjects.where(project: @project)
    if @operator == '=' || @operator.blank?
      subject_scope.where(id: @project.subjects.randomized.select(:id))
    elsif @operator == '!='
      subject_scope.where(id: @project.subjects.unrandomized.select(:id))
    else
      Subject.none
    end
  end

  def compute_sheets_for_checks
    sheet_scope = all_viewable_sheets
    return sheet_scope if @checks.count == 0
    sheet_ids = []
    @checks.each do |check|
      sheet_ids << check.sheets(current_user).pluck(:id)
    end
    sheet_ids.flatten!
    sheet_scope.where(id: sheet_ids)
  end

  def compute_sheets_for_variable
    sheet_scope = all_viewable_sheets
    return sheet_scope if @values.count == 0
    select_sheet_ids = subquery_scope.where(variable: @variable).where(subquery).select(:sheet_id)

    if %w(missing unentered blank).include?(@operator)
      sheet_scope.where.not(id: select_sheet_ids)
    else
      sheet_scope.where(id: select_sheet_ids)
    end
  end

  def all_viewable_sheets
    @current_user.all_viewable_sheets.where(project: @project)
  end

  def all_numeric?
    (@variable.captured_values + @values).uniq.count { |v| (v =~ /^[-+]?[0-9]*\.?[0-9]*$/).nil? } == 0
  end

  def subquery_attribute
    case @variable.variable_type
    when 'checkbox'
      'value'
    when 'file'
      'response_file'
    else
      'response'
    end
  end

  def subquery_scope
    @variable.variable_type == 'checkbox' ? Response : SheetVariable
  end

  def subjects(current_user)
    if @variable
      compute_subjects_for_variable(@current_user)
    elsif filter_type == 'randomized'
      randomized_subjects(@current_user)
    else
      Subject.none
    end
  end

  def compute_subjects_for_variable(current_user)
    @current_user.all_viewable_subjects
                 .where(project: project)
                 .where(id: sheets.select(:subject_id))
  end

  def subquery
    type_cast = all_numeric? ? 'numeric' : 'text'

    if @operator.in?(%w(< > <= >=))
      full_expression = []
      @values.each do |subquery_value|
        value = all_numeric? ? subquery_value : ActiveRecord::Base.sanitize(subquery_value)
        full_expression << "NULLIF(#{subquery_attribute}, '')::#{type_cast} #{database_operator} #{value}"
      end
      full_expression.join(' or ')
    else
      extra = ''
      extra = " or NULLIF(#{subquery_attribute}, '')::#{type_cast} IS NULL" if @operator == '!='
      "NULLIF(#{subquery_attribute}, '')::#{type_cast} #{database_operator} (#{subquery_values_joined})#{extra}"
    end
  end

  def database_operator
    case @operator
    when '<', '>', '<=', '>='
      @operator
    when '!='
      'NOT IN'
    when 'entered', 'present', 'any', 'missing', 'unentered', 'blank'
      'IN'
    else
      'IN'
    end
  end

  def subquery_values_joined
    if all_numeric?
      @values.sort.join(', ')
    else
      @values.collect { |v| ActiveRecord::Base.sanitize(v) }.sort.join(', ')
    end
  end
end
