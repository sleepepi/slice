# frozen_string_literal: true

# Allows filtering subjects.
class SearchSubject
  def self.subjects(project, current_user, scope, token)
    new(project, current_user, scope, token).subjects
  end

  attr_accessor :project, :scope, :token, :current_user, :variable

  def initialize(project, current_user, scope, token)
    @project = project
    @current_user = current_user
    @scope = scope
    @token = token
    unify_token_operator
  end

  def unify_token_operator
    @token.operator = \
      case @token.operator
      when "!=", "!"
        "!"
      else
        @token.operator
      end
  end

  def subjects
    case @token.key
    when "adverse-events"
      filter_adverse_events
    when "comments"
      filter_comments
    when "designs"
      filter_designs
    when "events"
      filter_events
    when "files"
      filter_files
    when "randomized"
      filter_randomized
    else
      event = find_event
      (design, modifier) = find_design_and_modifier

      if event && design
        subjects = @scope.joins(:subject_events).where(subject_events: { event: event })
        case modifier
        when "missing"
          subjects.joins(subject_events: :sheets)
                  .where(subject_events: { event: event, sheets: { design: design, missing: true } })
        when "unentered"
          subjects.where.not(
            id: subjects.joins(subject_events: :sheets)
                        .where(subject_events: { event: event, sheets: { design: design, missing: [true, false] } })
                        .select(:id)
          )
        else
          subjects.joins(subject_events: :sheets)
                  .where(subject_events: { event: event, sheets: { design: design, missing: false } })
        end
      else
        @scope.none
      end
    end
  end

  def filter_adverse_events
    if !@project.unblinded?(current_user)
      @scope.none
    elsif @token.value == "open"
      @scope.open_aes
    elsif @token.value == "closed"
      @scope.closed_aes
    elsif %w(missing !).include?(@token.operator)
      @scope.where.not(id: @scope.any_aes.select(:id))
    else
      @scope.any_aes
    end
  end

  def filter_comments
    subject_ids = all_viewable_sheets.where.not(comments_count: 0).select(:subject_id)
    if %w(missing !).include?(@token.operator)
      @scope.where.not(id: subject_ids)
    else
      @scope.where(id: subject_ids)
    end
  end

  def filter_designs
    set_designs
    return @scope if @designs.blank?
    subject_ids = @scope.joins(:sheets).where(sheets: { design: @designs }).select(:id)
    if %w(missing !).include?(@token.operator)
      @scope.where.not(id: subject_ids)
    else
      @scope.where(id: subject_ids)
    end
  end

  def filter_events
    set_events
    return @scope if @events.blank?
    subject_ids = @scope.joins(:subject_events).where(subject_events: { event: @events }).select(:id)
    if %w(missing !).include?(@token.operator)
      @scope.where.not(id: subject_ids)
    else
      @scope.where(id: subject_ids)
    end
  end

  def filter_files
    subject_ids = all_viewable_sheets.where.not(uploaded_files_count: [nil, 0]).select(:subject_id)
    if %w(missing !).include?(@token.operator)
      @scope.where.not(id: subject_ids)
    else
      @scope.where(id: subject_ids)
    end
  end

  def filter_randomized
    if @token.operator == "!"
      @scope.unrandomized
    else
      @scope.randomized
    end
  end

  def set_designs
    @designs = \
      if %w(present missing).include?(@token.operator)
        @project.designs
      else
        @project.designs.where(
          "slug ilike any (array[?]) or id IN (?)",
          @token.values,
          @token.values.collect(&:to_i)
        )
      end
  end

  def set_events
    @events = \
      if %w(present missing).include?(@token.operator)
        @project.events
      else
        @project.events.where(
          "slug ilike any (array[?]) or id IN (?)",
          @token.values,
          @token.values.collect(&:to_i)
        )
      end
  end

  def find_event
    @project.events.find_by("slug ilike ? or id = ?", @token.key, @token.key.to_i)
  end

  def find_design_and_modifier
    (design_slug, modifier) = @token.value.split(":", 2)
    design = \
      if design_slug
        @project.designs.find_by("slug ilike ? or id = ?", design_slug, design_slug.to_i)
      end
    [design, modifier]
  end

  def all_viewable_sheets
    @current_user.all_viewable_sheets.where(project: @project)
  end
end
