# frozen_string_literal: true

# Allow project and site editors to modify sheets, and project and site viewers
# to view and print sheets.
class SheetsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_project_or_redirect, only: [
    :index, :search, :show, :file, :coverage, :calculations
  ]
  before_action :find_editable_project_or_redirect, only: [:unlock]
  before_action :find_editable_project_or_editable_site_or_redirect, only: [
    :edit, :reassign, :move_to_event, :remove_shareable_link, :transactions,
    :new, :create, :update, :destroy, :set_as_not_missing, :change_event,
    :submit_change_event
  ]
  before_action :find_subject_or_redirect, only: [:create]
  before_action :find_viewable_sheet_or_redirect, only: [
    :show, :file, :coverage
  ]
  before_action :find_editable_sheet_or_redirect, only: [
    :edit, :reassign, :move_to_event, :update, :destroy,
    :remove_shareable_link, :transactions, :unlock, :set_as_not_missing,
    :change_event, :submit_change_event
  ]
  before_action :redirect_with_auto_locked_sheet, only: [
    :edit, :reassign, :update, :destroy, :change_event, :submit_change_event
  ]

  layout "layouts/full_page_sidebar_dark"

  # GET /sheets
  def index
    scope = current_user.all_viewable_sheets.where(project_id: @project.id).where(missing: false)
    scope = scope_includes(scope)
    scope = scope_search_filter(scope, params[:search])
    scope = scope_filter(scope)
    @sheets = scope_order(scope).page(params[:page]).per(40)
  end

  # GET /sheets/calculations
  def calculations
    scope = SheetError.joins(:sheet).merge(current_user.all_viewable_sheets.where(project_id: @project.id).where(missing: false))
    @sheet_errors = scope.search_any_order(params[:search]).order(:id).page(params[:page]).per(20)
  end

  # GET /sheets/search.json
  def search
    array = []
    if %w(full-word-colon).include?(params[:scope])
      (key, val) = params[:search].to_s.split(":", 2)
      words_for(key, @project).each do |word, label|
        array << { label: label, value: [key, word].join(":") } if starts_with?(val, word) || contains_word?(val, label)
      end
      options_start_with?(key, val).each do |option|
        array << { label: option.value_and_name.truncate(40), value: [key, option.value].join(":") }
      end
      other_words(key, @project).each do |word, label|
        array << { label: label, value: [key, word].join(":") } if starts_with?(val, word)
      end
    elsif %w(full-word-comma).include?(params[:scope])
      (key, value_string) = params[:search].to_s.split(":", 2)
      values = value_string.split(",", -1)
      val = values.present? ? values.pop : ""
      words_for(key, @project).each do |word, label|
        if starts_with?(val, word) || contains_word?(val, label)
          value_string = (values + [word]).join(",")
          array << { label: label, value: [key, value_string].join(":") }
        end
      end
      options_start_with?(key, val).each do |option|
        value_string = (values + [option.value]).join(",")
        array << { label: option.value_and_name.truncate(40), value: [key, value_string].join(":") }
      end
    elsif params[:scope] == ""
      %w(adverse-events checks coverage designs events has is no not).each do |word|
        val = params[:search].to_s
        array << { value: word } if starts_with?(val, word)
      end
      array += variables_start_with?(params[:search].to_s)
      array.sort_by! { |hash| hash[:value] }
    end
    render json: array
  end

  # GET /sheets/1
  # GET /sheets/1.pdf
  def show
    generate_pdf if params[:format] == "pdf"
  end

  # POST /sheets/1/coverage.js
  def coverage
    @sheet.check_coverage
  end

  # # GET /sheets/1/transactions
  # def transactions
  # end

  # GET /sheets/new
  def new
    redirect_to @project, notice: "Sheet creation is launched from subject pages."
  end

  # # GET /sheets/1/edit
  # def edit
  # end

  def file
    @sheet_variable = @sheet.sheet_variables.find_by(id: params[:sheet_variable_id])
    send_file_if_present @sheet_variable&.response_file
  end

  # POST /sheets
  def create
    @sheet = current_user.sheets.where(project_id: @project.id, subject_id: @subject.id).new(sheet_params)
    if SheetTransaction.save_sheet!(@sheet, sheet_params, variables_params, current_user, request.remote_ip, "sheet_create")
      redirect_to [@sheet.project, @sheet], notice: "Sheet was successfully created."
    else
      render :new
    end
  end

  # PATCH /sheets/1
  def update
    if SheetTransaction.save_sheet!(@sheet, sheet_params, variables_params, current_user, request.remote_ip, "sheet_update")
      redirect_to [@sheet.project, @sheet], notice: "Sheet was successfully updated."
    else
      render :edit
    end
  end

  # POST /sheets/1/unlock
  def unlock
    @sheet.reset_auto_lock!(current_user, request)
    redirect_to [@project, @sheet], notice: "Sheet was successfully unlocked."
  end

  # POST /sheets/1/set_as_not_missing.js
  def set_as_not_missing
    @sheet.destroy if @sheet.missing?
    @subject = @sheet.subject
    render :subject_event
  end

  # GET /sheets/1/reassign
  # POST /sheets/1/reassign?subject_id=1
  def reassign
    original_subject = @sheet.subject
    subject = @project.subjects.find_by(id: params[:subject_id])
    if subject && subject == original_subject
      redirect_to [@project, @sheet], alert: "No changes made to sheet."
    elsif subject
      notice = if params[:undo] == "1"
                 "Your action has been undone."
               else
                 ["Reassigned sheet to <b>#{subject.subject_code}</b>.", { label: "Undo", url: reassign_project_sheet_path(@project, @sheet, subject_id: original_subject.id, undo: "1"), method: :patch }]
               end
      SheetTransaction.save_sheet!(@sheet, { subject_id: subject.id, subject_event_id: nil, last_user_id: current_user.id, last_edited_at: Time.zone.now }, {}, current_user, request.remote_ip, "sheet_update", skip_validation: true)
      redirect_to [@project, @sheet], notice: notice
    end
  end

  # # GET /sheets/1/change-event
  # def change_event
  # end

  # POST /sheets/1/change-event
  def submit_change_event
    @sheet.subject_event&.reset_coverage!
    subject_event = @sheet.subject.subject_events.find_by(id: params[:sheet][:subject_event_id])
    subject_event&.reset_coverage!
    SheetTransaction.save_sheet!(
      @sheet, {
        subject_event_id: subject_event&.id,
        last_user_id: current_user.id, last_edited_at: Time.zone.now
      }, {}, current_user, request.remote_ip, "sheet_update", skip_validation: true
    )
    redirect_to [@project, @sheet], notice: "Event was successfully updated."
  end

  # PATCH /sheets/1/move_to_event
  def move_to_event
    return if @sheet.auto_locked?
    @sheet.subject_event.reset_coverage! if @sheet.subject_event
    subject_event = @sheet.subject.subject_events.find_by(id: params[:subject_event_id])
    subject_event.reset_coverage! if subject_event
    SheetTransaction.save_sheet!(
      @sheet, {
        subject_event_id: subject_event ? subject_event.id : nil,
        last_user_id: current_user.id, last_edited_at: Time.zone.now
      }, {}, current_user, request.remote_ip, "sheet_update", skip_validation: true
    )
  end

  # POST /sheets/1/remove_shareable_link
  def remove_shareable_link
    @sheet.update authentication_token: nil
    redirect_to [@project, @sheet]
  end

  # DELETE /sheets/1
  def destroy
    @sheet.destroy
    respond_to do |format|
      format.html { redirect_to project_subject_path(@project, @sheet.subject) }
      format.js
    end
  end

  private

  def find_viewable_sheet_or_redirect
    @sheet = current_user.all_viewable_sheets.includes(:design).find_by(id: params[:id])
    redirect_without_sheet
  end

  def find_editable_sheet_or_redirect
    @sheet = current_user.all_sheets.includes(:design).find_by(id: params[:id])
    redirect_without_sheet
  end

  def find_subject_or_redirect
    @subject = current_user.all_subjects.where(project: @project).find_by(id: params[:subject_id])
    redirect_without_subject
  end

  def redirect_without_subject
    empty_response_or_root_path(@project) unless @subject
  end

  def redirect_without_sheet
    empty_response_or_root_path(project_sheets_path(@project)) unless @sheet
  end

  def redirect_with_auto_locked_sheet
    redirect_to [@sheet.project, @sheet], notice: "This sheet is locked." if @sheet.auto_locked?
  end

  def sheet_params
    params[:sheet] ||= {}
    params[:sheet][:last_user_id] = current_user.id
    params[:sheet][:last_edited_at] = Time.zone.now
    params.require(:sheet).permit(
      :design_id, :variable_ids, :last_user_id, :last_edited_at,
      :subject_event_id, :adverse_event_id, :ae_adverse_event_id, :missing
    )
  end

  def variables_params
    (params[:variables].blank? ? {} : params.require(:variables).permit!)
  end

  def generate_pdf
    sheet_print = @sheet.sheet_prints.where(language: World.language).first_or_create
    sheet_print.regenerate! if sheet_print.regenerate?
    send_file_if_present sheet_print.file, type: "application/pdf", disposition: "inline"
  end

  # TODO: Unify these with those in export.rb
  def scope_search_filter(scope, search)
    @tokens = Search.pull_tokens(search)
    @tokens.reject { |t| t.key == "search" }.each do |token|
      case token.key
      when "created"
        scope = scope_by_date(scope, token)
      else
        scope = scope_by_variable(scope, token)
      end
    end
    terms = @tokens.select { |t| t.key == "search" }.collect(&:value)
    scope.search(terms.join(" "))
  end

  def scope_by_date(scope, token)
    (first_date, last_date) = smart_date_parse(token)
    case token.operator
    when "<"
      scope = scope.sheet_before(first_date - 1.day)
    when ">"
      scope = scope.sheet_after(last_date + 1.day)
    when "<="
      scope = scope.sheet_before(last_date)
    when ">="
      scope = scope.sheet_after(first_date)
    else
      scope = scope.sheet_before(last_date).sheet_after(first_date)
    end
    scope
  rescue
    scope
  end

  def smart_date_parse(token)
    if !(/^\d{4}$/ =~ token.value).nil?
      first_date = Date.strptime("#{token.value}-01-01", "%Y-%m-%d")
      last_date = first_date.end_of_year
    elsif !(/^\d{4}-\d{1,2}$/ =~ token.value).nil?
      first_date = Date.strptime("#{token.value}-01", "%Y-%m-%d")
      last_date = first_date.end_of_month
    else
      first_date = Date.strptime(token.value, "%Y-%m-%d")
      last_date = first_date
    end
    [first_date, last_date]
  end

  def scope_by_variable(scope, token)
    Search.run_sheets(@project, current_user, scope, token)
  end

  def scope_includes(scope)
    scope.includes(:design, :subject, { subject: :site }, :user)
  end

  def scope_filter(scope)
    scope = scope.with_site(params[:site_id]) if params[:site_id].present?
    [:user_id].each do |key|
      scope = scope.where(key => params[key]) if params[key].present?
    end
    scope
  end

  def scope_order(scope)
    @order = params[:order]
    scope.order(Arel.sql(Sheet::ORDERS[params[:order]] || Sheet::DEFAULT_ORDER))
  end

  def starts_with?(search, word)
    !(/^#{search}/i =~ word).nil?
  end

  def contains_word?(search, label)
    !(/#{search}/i =~ label).nil?
  end

  # terms = ["adverse-events", "designs", "events", "has", "is", "no", "not"]
  def words_for(key, project)
    case key
    when "is", "not"
      %w(randomized).collect { |i| [i, i] }
    when "has", "no"
      %w(adverse-events comments files).collect { |i| [i, i] }
    when "design", "designs"
      project.designs.order(:slug, :name).collect { |d| [d.to_param, d.name] }
    when "event", "events"
      project.events.order(:slug, :name).collect { |e| [e.to_param, e.param_and_name] }
    when "check", "checks"
      project.checks.runnable.order(:slug, :name).collect { |c| [c.to_param, c.name] }
    else
      []
    end
  end

  # missing, present, unentered, entered, blank, open, closed
  def other_words(key, _project)
    # open closed for adverse-events
    case key
    when "is", "not", "no", "has", "design", "designs"
      []
    when "adverse-events"
      %w(open closed).collect { |i| [i, i] }
    when "checks"
      %w(present).collect { |i| [i, i] }
    when "event", "events"
      %w(present missing).collect { |i| [i, i] }
    when "coverage"
      %w(<70 >=70 missing).collect { |i| [i, i] }
    else
      %w(entered present missing unentered blank).collect { |i| [i, i] }
    end
  end

  def variables_start_with?(search)
    @project.variables
            .where(variable_type: Variable::TYPE_SEARCHABLE)
            .where("name ILIKE (?)", "#{search}%")
            .order(:name).select(:name).collect { |v| { value: v.name } }
  end

  def options_start_with?(key, val)
    variable = @project.variables.find_by(name: key)
    if variable
      variable.domain_options.where("value ILIKE (?) or name ILIKE (?)", "#{val}%", "%#{val}%")
    else
      DomainOption.none
    end
  end
end
