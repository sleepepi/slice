# frozen_string_literal: true

# Allow project and site editors to modify sheets, and project and site viewers
# to view and print sheets.
class SheetsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_project_or_redirect, only: [
    :index, :show, :file, :coverage
  ]
  before_action :find_editable_project_or_redirect, only: [:unlock]
  before_action :find_editable_project_or_editable_site_or_redirect, only: [
    :edit, :reassign, :move_to_event, :remove_shareable_link, :transactions,
    :new, :create, :update, :destroy, :set_as_not_missing
  ]
  before_action :find_subject_or_redirect, only: [:create]
  before_action :find_viewable_sheet_or_redirect, only: [
    :show, :file, :coverage
  ]
  before_action :find_editable_sheet_or_redirect, only: [
    :edit, :reassign, :move_to_event, :update, :destroy,
    :remove_shareable_link, :transactions, :unlock, :set_as_not_missing
  ]
  before_action :redirect_with_auto_locked_sheet, only: [
    :edit, :reassign, :update, :destroy
  ]

  # GET /sheets
  def index
    scope = current_user.all_viewable_sheets.where(project_id: @project.id).where(missing: false)
    scope = scope_includes(scope)
    scope = scope_search_filter(scope, params[:search])
    scope = scope_filter(scope)
    @sheets = scope_order(scope).page(params[:page]).per(40)
  end

  # GET /sheets/1
  # GET /sheets/1.pdf
  def show
    generate_pdf if params[:format] == 'pdf'
  end

  # POST /sheets/1/coverage.js
  def coverage
    @sheet.check_response_count_change
  end

  # # GET /sheets/1/transactions
  # def transactions
  # end

  # GET /sheets/new
  def new
    redirect_to @project, notice: 'Sheet creation is launched from subject pages.'
  end

  # # GET /sheets/1/edit
  # def edit
  # end

  def file
    @sheet_variable = @sheet.sheet_variables.find_by(id: params[:sheet_variable_id])
    @object = if params[:position].blank? || params[:variable_id].blank?
                @sheet_variable
              else
                # Grid
                @sheet_variable.grids.find_by(variable_id: params[:variable_id], position: params[:position].to_i) if @sheet_variable
              end
    if @object && @object.response_file.size > 0
      send_file File.join(CarrierWave::Uploader::Base.root, @object.response_file.url)
    else
      head :ok
    end
  end

  # POST /sheets
  def create
    @sheet = current_user.sheets.where(project_id: @project.id, subject_id: @subject.id).new(sheet_params)
    if SheetTransaction.save_sheet!(@sheet, sheet_params, variables_params, current_user, request.remote_ip, 'sheet_create')
      notices = []
      notices << 'Sheet was successfully created.'
      notices << { label: 'Create another?', url:  new_data_entry_project_subject_path(@project, @subject, @sheet.design), class: 'fa-plus-square' }
      redirect_to [@sheet.project, @sheet], notice: @sheet.design.repeated? ? notices : notices.first
    else
      render :new
    end
  end

  # PATCH /sheets/1
  def update
    if SheetTransaction.save_sheet!(@sheet, sheet_params, variables_params, current_user, request.remote_ip, 'sheet_update')
      redirect_to [@sheet.project, @sheet], notice: 'Sheet was successfully updated.'
    else
      render :edit
    end
  end

  # POST /sheets/1/unlock
  def unlock
    @sheet.reset_auto_lock!(current_user, request)
    redirect_to [@project, @sheet], notice: 'Sheet was successfully unlocked.'
  end

  # POST /sheets/1/set_as_not_missing
  def set_as_not_missing
    if @sheet.missing?
      SheetTransaction.save_sheet!(@sheet, { unlocked_at: Time.zone.now, last_user_id: current_user.id, last_edited_at: Time.zone.now, missing: false }, {}, current_user, request.remote_ip, 'sheet_update', skip_validation: true)
      flash[:notice] = 'Sheet was successfully set as not missing.'
    end
    redirect_to [@project, @sheet]
  end

  # GET /sheets/1/reassign
  # POST /sheets/1/reassign?subject_id=1
  def reassign
    original_subject = @sheet.subject
    subject = @project.subjects.find_by(id: params[:subject_id])
    if subject && subject == original_subject
      redirect_to [@project, @sheet], alert: 'No changes made to sheet.'
    elsif subject
      notice = if params[:undo] == '1'
                 'Your action has been undone.'
               else
                 ["Reassigned sheet to <b>#{subject.subject_code}</b>.", { label: 'Undo', url: reassign_project_sheet_path(@project, @sheet, subject_id: original_subject.id, undo: '1'), method: :patch }]
               end
      SheetTransaction.save_sheet!(@sheet, { subject_id: subject.id, subject_event_id: nil, last_user_id: current_user.id, last_edited_at: Time.zone.now }, {}, current_user, request.remote_ip, 'sheet_update', skip_validation: true)
      redirect_to [@project, @sheet], notice: notice
    end
  end

  # PATCH /sheets/1/move_to_event
  def move_to_event
    return if @sheet.auto_locked?
    subject_event = @sheet.subject.subject_events.find_by(id: params[:subject_event_id])
    SheetTransaction.save_sheet!(
      @sheet, {
        subject_event_id: subject_event ? subject_event.id : nil,
        last_user_id: current_user.id, last_edited_at: Time.zone.now
      }, {}, current_user, request.remote_ip, 'sheet_update', skip_validation: true
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
    @sheet = current_user.all_sheets.find_by(id: params[:id])
    redirect_without_sheet
  end

  def find_subject_or_redirect
    @subject = current_user.all_subjects.where(project_id: @project.id).find_by(id: params[:subject_id])
    redirect_without_subject
  end

  def redirect_without_subject
    empty_response_or_root_path(@project) unless @subject
  end

  def redirect_without_sheet
    empty_response_or_root_path(project_sheets_path(@project)) unless @sheet
  end

  def redirect_with_auto_locked_sheet
    redirect_to [@sheet.project, @sheet], notice: 'This sheet is locked.' if @sheet.auto_locked?
  end

  def sheet_params
    params[:sheet] ||= {}
    params[:sheet][:last_user_id] = current_user.id
    params[:sheet][:last_edited_at] = Time.zone.now
    params.require(:sheet).permit(
      :design_id, :variable_ids, :last_user_id, :last_edited_at,
      :subject_event_id, :adverse_event_id, :missing
    )
  end

  def variables_params
    (params[:variables].blank? ? {} : params.require(:variables).permit!)
  end

  def generate_pdf
    pdf_location = Sheet.latex_file_location([@sheet], current_user)
    if File.exist?(pdf_location)
      send_file pdf_location, filename: "sheet_#{@sheet.id}.pdf", type: 'application/pdf', disposition: 'inline'
    else
      redirect_to [@project, @sheet], alert: 'Unable to generate PDF.'
    end
  end

  def scope_search_filter(scope, search)
    @tokens = Search.pull_tokens(search)
    @tokens.reject { |t| t.key == 'search' }.each do |token|
      case token.key
      when 'created'
        scope = scope_by_date(scope, token)
      else
        scope = scope_by_variable(scope, token)
      end
    end
    terms = @tokens.select { |t| t.key == 'search' }.collect(&:value)
    scope.search(terms.join(' '))
  end

  def scope_by_date(scope, token)
    date = Date.strptime(token.value, '%Y-%m-%d')
    case token.operator
    when '<'
      scope = scope.sheet_before(date - 1.day)
    when '>'
      scope = scope.sheet_after(date + 1.day)
    when '<='
      scope = scope.sheet_before(date)
    when '>='
      scope = scope.sheet_after(date)
    else
      scope = scope.sheet_before(date).sheet_after(date)
    end
    scope
  rescue
    scope
  end

  def scope_by_variable(scope, token)
    Search.run_sheets(@project, current_user, scope, token)
  end

  def scope_includes(scope)
    scope.includes(:design, :subject, { subject: :site }, :user)
  end

  def scope_filter(scope)
    scope = scope.with_site(params[:site_id]) if params[:site_id].present?
    [:design_id, :user_id].each do |key|
      scope = scope.where(key => params[key]) if params[key].present?
    end
    scope
  end

  def scope_order(scope)
    @order = params[:order]
    scope.order(Sheet::ORDERS[params[:order]] || Sheet::DEFAULT_ORDER)
  end
end
