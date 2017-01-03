# frozen_string_literal: true

# Allows searching of sheets by variable.
class Search
  def self.run_sheets(project, current_user, sheet_scope, token)
    new(project, current_user, sheet_scope, token).run_sheets
  end

  def self.pull_tokens(search)
    search.to_s.squish.split(/\s(?=(?:[^"]|"[^"]*")*$)/).collect do |part|
      ::Token.parse(part)
    end
  end

  attr_accessor :project, :sheet_scope, :token, :current_user, :variable

  def initialize(project, current_user, sheet_scope, token)
    @project = project
    @current_user = current_user
    @sheet_scope = sheet_scope
    @token = token
    @operator = token.operator
    set_checks_or_variable
  end

  def set_checks_or_variable
    case @token.key
    when 'checks'
      set_checks
    when 'designs', 'design'
      set_designs
    when 'events'
      set_events
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
    @checks = \
      if @operator == 'any'
        @project.checks.runnable
      else
        @project.checks.where(slug: @token.values)
      end
  end

  def set_designs
    @designs = \
      if %w(any missing).include?(@operator)
        @project.designs
      else
        @project.designs.where(
          'slug ilike any (array[?]) or id IN (?)',
          @token.values,
          @token.values.collect(&:to_i)
        )
      end
  end

  def set_events
    @events = \
      if %w(any missing).include?(@operator)
        @project.events
      else
        @project.events.where(
          'slug ilike any (array[?]) or id IN (?)',
          @token.values,
          @token.values.collect(&:to_i)
        )
      end
  end

  def set_variable
    @variable = @project.variables.find_by_name(@token.key)
    return unless @variable
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
      @values = parse_values_for_variable
    end
  end

  def parse_values_for_variable
    values = @token.values.reject(&:blank?).collect(&:strip).reject(&:blank?).uniq.collect do |val|
      if !(/^(\d+)s$/ =~ val).nil?
        val.gsub(/s$/, '')
      elsif !(/^(\d+)m$/ =~ val).nil?
        (val.gsub(/m$/, '').to_i * 60).to_s
      elsif !(/^(\d+)h$/ =~ val).nil?
        (val.gsub(/h$/, '').to_i * 3600).to_s
      elsif !(/^(\d+)oz$/ =~ val).nil?
        val.gsub(/oz$/, '')
      elsif !(/^(\d+)lb$/ =~ val).nil?
        (val.gsub(/lb$/, '').to_i * 16).to_s
      elsif !(/^(\d+)in$/ =~ val).nil?
        val.gsub(/in$/, '')
      elsif !(/^(\d+)ft$/ =~ val).nil?
        (val.gsub(/ft$/, '').to_i * 12).to_s
      else
        val
      end
    end
    values.uniq
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
    elsif @designs
      compute_sheets_for_designs
    elsif @events
      compute_sheets_for_events
    elsif @variable
      compute_sheets_for_variable
    elsif @token.key == 'randomized'
      randomized_subjects_sheets
    elsif @token.key == 'coverage'
      compute_sheets_for_coverage
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
    return sheet_scope if @checks.count.zero?
    sheet_ids = StatusCheck.where(check_id: @checks.select(:id), failed: true).select(:sheet_id)
    sheet_scope.where(id: sheet_ids)
  end

  def compute_sheets_for_designs
    sheet_scope = all_viewable_sheets
    return sheet_scope if @designs.count.zero?
    if @operator == 'missing'
      sheet_scope.where.not(design_id: @designs.select(:id))
    else
      sheet_scope.where(design_id: @designs.select(:id))
    end
  end

  def compute_sheets_for_events
    sheet_scope = all_viewable_sheets
    return sheet_scope if @events.count.zero?
    sheet_ids = []
    @events.each do |event|
      sheet_ids << all_viewable_sheets.where(subject_events: { event_id: event.id }).pluck(:id)
    end
    sheet_ids.flatten!

    if @operator == 'missing'
      sheet_scope.where.not(id: sheet_ids)
    else
      sheet_scope.where(id: sheet_ids)
    end
  end

  def compute_sheets_for_variable
    sheet_scope = all_viewable_sheets
    return sheet_scope if @values.count == 0
    select_sheet_ids = subquery_scope.where(variable: @variable).left_outer_joins(:domain_option).where(subquery).select(:sheet_id)

    if %w(missing unentered blank).include?(@operator)
      sheet_scope.where.not(id: select_sheet_ids)
    else
      sheet_scope.where(id: select_sheet_ids)
    end
  end

  def compute_sheets_for_coverage
    sheet_scope = all_viewable_sheets
    if %w(missing unentered blank).include?(@operator)
      sheet_scope.where(percent: nil)
    elsif %w(any entered present).include?(@operator)
      sheet_scope.where.not(percent: nil)
    elsif @operator.in?(%w(< > <= >=))
      sheet_scope.where("sheets.percent #{database_operator} ?", @token.value.to_i)
    else
      sheet_scope.where("sheets.percent #{database_operator} (?)", @token.values.collect(&:to_i))
    end
  end

  def all_viewable_sheets
    @current_user.all_viewable_sheets.where(project: @project)
  end

  def all_numeric?
    (@variable.captured_values + @values).uniq.count { |v| (v =~ /^[-+]?[0-9]*\.?[0-9]*$/).nil? } == 0
  end

  # TODO: `response` will be changed to `value` in the future
  def subquery_attribute
    case @variable.variable_type
    when 'checkbox'
      "#{subquery_scope.table_name}.value"
    when 'file'
      "#{subquery_scope.table_name}.response_file"
    else
      "#{subquery_scope.table_name}.response"
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
        full_expression << "#{domain_option_value_or_attribute(type_cast)} #{database_operator} #{value}"
      end
      full_expression.join(' or ')
    else
      extra = ''
      extra = " or #{domain_option_value_or_attribute(type_cast)} IS NULL" if @operator == '!='
      "#{domain_option_value_or_attribute(type_cast)} #{database_operator} (#{subquery_values_joined})#{extra}"
    end
  end

  def domain_option_value_or_attribute(type_cast)
    field_one = "NULLIF(domain_options.value, '')::#{type_cast}"
    field_two = "NULLIF(#{subquery_attribute}, '')::#{type_cast}"
    "(CASE WHEN (#{field_one} IS NULL) THEN #{field_two} ELSE #{field_one} END)"
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
