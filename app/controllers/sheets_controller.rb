# frozen_string_literal: true

# Allow project and site editors to modify sheets, and project and site viewers
# to view and print sheets.
class SheetsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_project_or_redirect, only: [:index, :show, :file]
  before_action :find_editable_project_or_redirect, only: [:unlock]
  before_action :find_editable_project_or_editable_site_or_redirect, only: [
    :edit, :reassign, :move_to_event, :remove_shareable_link, :transactions,
    :new, :create, :update, :destroy, :set_as_not_missing
  ]
  before_action :find_subject_or_redirect, only: [:create]
  before_action :find_viewable_sheet_or_redirect, only: [:show, :file]
  before_action :find_editable_sheet_or_redirect, only: [
    :edit, :reassign, :move_to_event, :update, :destroy,
    :remove_shareable_link, :transactions, :unlock, :set_as_not_missing
  ]
  before_action :redirect_with_auto_locked_sheet, only: [
    :edit, :reassign, :update, :destroy
  ]

  # GET /sheets
  def index
    sheet_scope = current_user.all_viewable_sheets.where(project_id: @project.id).where(missing: false)

    sheet_scope = filter_scope(sheet_scope, params[:search])

    %w(design site user).each do |filter|
      sheet_scope = sheet_scope.send("with_#{filter}", params["#{filter}_id".to_sym]) unless params["#{filter}_id".to_sym].blank?
    end

    @order = params[:order]
    case params[:order]
    when 'sheets.site_name'
      sheet_scope = sheet_scope.includes(subject: :site).order('sites.name')
    when 'sheets.site_name desc'
      sheet_scope = sheet_scope.includes(subject: :site).order('sites.name desc')
    when 'sheets.design_name'
      sheet_scope = sheet_scope.includes(:design).order('designs.name').select('sheets.*, designs.name')
    when 'sheets.design_name desc'
      sheet_scope = sheet_scope.includes(:design).order('designs.name desc').select('sheets.*, designs.name')
    when 'sheets.subject_code'
      sheet_scope = sheet_scope.order('subjects.subject_code').select('sheets.*, subjects.subject_code')
    when 'sheets.subject_code desc'
      sheet_scope = sheet_scope.order('subjects.subject_code desc').select('sheets.*, subjects.subject_code')
    when 'sheets.user_name'
      sheet_scope = sheet_scope.includes(:user).order('users.last_name, users.first_name')
    when 'sheets.user_name desc'
      sheet_scope = sheet_scope.includes(:user).order('users.last_name desc, users.first_name desc')
    else
      @order = scrub_order(Sheet, params[:order], 'sheets.created_at desc')
      sheet_scope = sheet_scope.order(@order)
    end

    @sheets = sheet_scope.page(params[:page]).per(40)
  end

  # GET /sheets/1
  # GET /sheets/1.pdf
  def show
    generate_pdf if params[:format] == 'pdf'
  end

  # GET /sheets/1/transactions
  def transactions
  end

  # GET /sheets/new
  def new
    redirect_to @project, notice: 'Sheet creation is launched from subject pages.'
  end

  # GET /sheets/1/edit
  def edit
  end

  def file
    @sheet_variable = @sheet.sheet_variables.find_by_id(params[:sheet_variable_id])
    @object = if params[:position].blank? || params[:variable_id].blank?
      @sheet_variable
    else
      @sheet_variable.grids.find_by_variable_id_and_position(params[:variable_id], params[:position].to_i) if @sheet_variable  # Grid
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
      redirect_to [@sheet.project, @sheet], notice: 'Sheet was successfully created.'
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
      SheetTransaction.save_sheet!(@sheet, { unlocked_at: Time.zone.now, last_user_id: current_user.id, last_edited_at: Time.zone.now, missing: false }, {}, current_user, request.remote_ip, 'sheet_update')
      flash[:notice] = 'Sheet was successfully set as not missing.'
    end
    redirect_to [@project, @sheet]
  end

  # GET /sheets/1/reassign
  # POST /sheets/1/reassign?subject_id=1
  def reassign
    original_subject = @sheet.subject
    subject = @project.subjects.find_by_id(params[:subject_id])
    if subject && subject == original_subject
      redirect_to [@project, @sheet], alert: 'No changes made to sheet.'
    elsif subject
      notice = if params[:undo] == '1'
                 'Your action has been undone.'
               else
                 ["Reassigned sheet to <b>#{subject.subject_code}</b>.", { label: 'Undo', url: reassign_project_sheet_path(@project, @sheet, subject_id: original_subject.id, undo: '1'), method: :patch }]
               end
      SheetTransaction.save_sheet!(@sheet, { subject_id: subject.id, subject_event_id: nil, last_user_id: current_user.id, last_edited_at: Time.zone.now }, {}, current_user, request.remote_ip, 'sheet_update')
      redirect_to [@project, @sheet], notice: notice
    end
  end

  def move_to_event
    subject_event = @sheet.subject.subject_events.find_by_id(params[:subject_event_id])
    if subject_event && !@sheet.auto_locked?
      SheetTransaction.save_sheet!(@sheet, { subject_event_id: subject_event.id, last_user_id: current_user.id, last_edited_at: Time.zone.now }, {}, current_user, request.remote_ip, 'sheet_update')
    end
  end

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
    @sheet = current_user.all_viewable_sheets.find_by_id(params[:id])
    redirect_without_sheet
  end

  def find_editable_sheet_or_redirect
    @sheet = current_user.all_sheets.find_by_id(params[:id])
    redirect_without_sheet
  end

  def find_subject_or_redirect
    @subject = current_user.all_subjects.where(project_id: @project.id).find_by_id params[:subject_id]
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
    current_time = Time.zone.now

    params[:sheet] ||= {}

    params[:sheet][:last_user_id] = current_user.id
    params[:sheet][:last_edited_at] = current_time

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
    if File.exist? pdf_location
      send_file pdf_location, filename: "sheet_#{@sheet.id}.pdf", type: 'application/pdf', disposition: 'inline'
    else
      redirect_to [@project, @sheet], alert: 'Unable to generate PDF.'
    end
  end

  def filter_scope(sheet_scope, search)
    tokens = pull_tokens(search)
    terms = []
    tokens.each do |token|
      if token[:key] == 'created'
        sheet_scope = scope_by_date(sheet_scope, token)
      elsif token[:key] == 'search'
        terms << token[:value]
      else
        sheet_scope = scope_by_variable(sheet_scope, token)
      end
    end
    sheet_scope = sheet_scope.search(terms.join(' '))
    sheet_scope
  end

  def pull_tokens(token_string)
    @tokens = token_string.to_s.squish.split(/\s/).collect do |part|
      operator = nil
      (key, value) = part.split(':')
      if value.blank?
        value = key
        key = 'search'
      elsif %w(has is).include?(key)
        key = value
        value = '1'
      elsif %w(not).include?(key)
        key = value
        value = '1'
        operator = '!='
      else
        operator = set_operator(value)
        value = value.gsub(/^#{operator}/, '') unless operator.nil?
      end
      { key: key, operator: operator, value: value }
    end
    @tokens
  end

  def set_operator(value)
    operator = nil
    found = ((/^>=|^<=|^>|^=|^<|!=|missing$|any$/).match(value))
    operator = found[0] if found
    operator
  end

  def scope_by_date(sheet_scope, token)
    date = Date.strptime(token[:value], '%Y-%m-%d')
    case token[:operator]
    when '<'
      sheet_scope = sheet_scope.sheet_before(date - 1.day)
    when '>'
      sheet_scope = sheet_scope.sheet_after(date + 1.day)
    when '<='
      sheet_scope = sheet_scope.sheet_before(date)
    when '>='
      sheet_scope = sheet_scope.sheet_after(date)
    else
      sheet_scope = sheet_scope.sheet_before(date).sheet_after(date)
    end
    sheet_scope
  rescue
    sheet_scope
  end

  def scope_by_variable(sheet_scope, token)
    Search.run_sheets(@project, current_user, sheet_scope, token)
  end
end
