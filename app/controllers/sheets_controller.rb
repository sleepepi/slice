# frozen_string_literal: true

class SheetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_project, only: [:index, :show, :print, :file]
  before_action :set_editable_project_or_editable_site, only: [:edit, :transfer, :move_to_event, :transactions, :new, :create, :update, :destroy, :unlock]
  before_action :redirect_without_project, only: [:index, :show, :print, :edit, :transfer, :move_to_event, :transactions, :new, :create, :update, :destroy, :unlock, :file]
  before_action :set_subject,              only: [:create]
  before_action :redirect_without_subject, only: [:create]
  before_action :set_viewable_sheet, only: [:show, :print, :file]
  before_action :set_editable_sheet, only: [:edit, :transfer, :move_to_event, :transactions, :update, :destroy, :unlock]
  before_action :redirect_without_sheet, only: [:show, :print, :edit, :transfer, :move_to_event, :transactions, :update, :destroy, :unlock, :file]
  before_action :redirect_with_locked_sheet, only: [:edit, :transfer, :move_to_event, :update, :destroy]

  # GET /sheets
  def index
    sheet_scope = current_user.all_viewable_sheets.where(project_id: @project.id).includes(:user, :design, subject: :site).search(params[:search])
    @sheet_after = parse_date(params[:sheet_after])
    @sheet_before = parse_date(params[:sheet_before])
    sheet_scope = sheet_scope.sheet_after(@sheet_after) unless @sheet_after.blank?
    sheet_scope = sheet_scope.sheet_before(@sheet_before) unless @sheet_before.blank?
    sheet_scope = sheet_scope.where(locked: true) if params[:locked].to_s == '1'
    sheet_scope = Sheet.filter_sheet_scope(sheet_scope, params[:f]).where(missing: false)

    %w(design site user).each do |filter|
      sheet_scope = sheet_scope.send("with_#{filter}", params["#{filter}_id".to_sym]) unless params["#{filter}_id".to_sym].blank?
    end

    @order = params[:order]
    case params[:order]
    when 'sheets.site_name'
      sheet_scope = sheet_scope.order('sites.name')
    when 'sheets.site_name DESC'
      sheet_scope = sheet_scope.order('sites.name desc')
    when 'sheets.design_name'
      sheet_scope = sheet_scope.order('designs.name').select('sheets.*, designs.name')
    when 'sheets.design_name DESC'
      sheet_scope = sheet_scope.order('designs.name desc').select('sheets.*, designs.name')
    when 'sheets.subject_code'
      sheet_scope = sheet_scope.order('subjects.subject_code').select('sheets.*, subjects.subject_code')
    when 'sheets.subject_code DESC'
      sheet_scope = sheet_scope.order('subjects.subject_code desc').select('sheets.*, subjects.subject_code')
    when 'sheets.user_name'
      sheet_scope = sheet_scope.order('users.last_name, users.first_name')
    when 'sheets.user_name DESC'
      sheet_scope = sheet_scope.order('users.last_name desc, users.first_name desc')
    else
      @order = scrub_order(Sheet, params[:order], 'sheets.created_at DESC')
      sheet_scope = sheet_scope.order(@order)
    end

    @sheets = sheet_scope.page(params[:page]).per(40)
  end

  # This is the latex view
  def print
    file_pdf_location = Sheet.latex_file_location([@sheet], current_user)

    if File.exist?(file_pdf_location)
      send_file file_pdf_location, filename: "sheet_#{@sheet.id}.pdf", type: 'application/pdf', disposition: 'inline'
    else
      render text: 'PDF did not render in time. Please refresh the page.'
    end
  end

  # GET /sheets/1
  def show
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

    if @object and @object.response_file.size > 0
      send_file File.join( CarrierWave::Uploader::Base.root, @object.response_file.url )
    else
      render nothing: true
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

  # GET /sheets/1/transfer
  # PUT /sheets/1/transfer?subject_id=1
  def transfer
    original_subject = @sheet.subject
    subject = @project.subjects.find_by_id(params[:subject_id])
    if subject && subject == original_subject
      redirect_to [@project, @sheet], alert: 'No changes made to sheet.'
    elsif subject
      notice = if params[:undo] == '1'
                 'Your action has been undone.'
               else
                 "Successfully transferred sheet from subject <b>#{original_subject.subject_code}</b> to <b>#{subject.subject_code}</b>. #{view_context.link_to 'Undo', transfer_project_sheet_path(@project, @sheet, subject_id: original_subject.id, undo: '1'), method: :patch}"
               end

      SheetTransaction.save_sheet!(@sheet, { subject_id: subject.id, subject_event_id: nil, last_user_id: current_user.id, last_edited_at: Time.zone.now }, {}, current_user, request.remote_ip, 'sheet_update')
      redirect_to [@project, @sheet], notice: notice
    end
  end

  def move_to_event
    subject_event = @sheet.subject.subject_events.find_by_id(params[:subject_event_id])
    if subject_event
      SheetTransaction.save_sheet!(@sheet, { subject_event_id: subject_event.id, last_user_id: current_user.id, last_edited_at: Time.zone.now }, {}, current_user, request.remote_ip, 'sheet_update')
    else
      render nothing: true
    end
  end

  # DELETE /sheets/1
  def destroy
    @sheet.destroy

    respond_to do |format|
      format.html { redirect_to project_subject_path(@project, @sheet.subject) }
      format.js
    end
  end

  def unlock
    if @project.lockable?
      flash[:notice] = 'Sheet was successfully unlocked.'
      SheetTransaction.save_sheet!(@sheet, { locked: false, last_user_id: current_user.id, last_edited_at: Time.zone.now }, {}, current_user, request.remote_ip, 'sheet_update')
    end
    respond_to do |format|
      format.html { redirect_to [@sheet.project, @sheet] }
      format.json { head :no_content }
    end
  end

  private

  def set_viewable_sheet
    @sheet = current_user.all_viewable_sheets.find_by_id(params[:id])
  end

  def set_editable_sheet
    @sheet = current_user.all_sheets.find_by_id(params[:id])
  end

  def set_subject
    @subject = current_user.all_subjects.where(project_id: @project.id).find_by_id params[:subject_id]
  end

  def redirect_without_subject
    empty_response_or_root_path(@project) unless @subject
  end

  def redirect_with_locked_sheet
    redirect_to [@sheet.project, @sheet] if @sheet.locked?
  end

  def redirect_without_sheet
    empty_response_or_root_path(project_sheets_path(@project)) unless @sheet
  end

  def sheet_params
    current_time = Time.zone.now

    params[:sheet] ||= {}

    params[:sheet][:last_user_id] = current_user.id
    params[:sheet][:last_edited_at] = current_time

    params[:sheet].delete(:locked) unless @project.lockable?
    if (@sheet && params[:sheet][:locked].to_s == '1' && !@sheet.first_locked_at) || (!@sheet && params[:sheet][:locked].to_s == '1')
      params[:sheet][:first_locked_at] = current_time
      params[:sheet][:first_locked_by_id] = current_user.id
    end

    params.require(:sheet).permit(
      :design_id, :variable_ids, :last_user_id, :last_edited_at,
      :locked, :first_locked_at, :first_locked_by_id,
      :subject_event_id, :adverse_event_id, :missing
    )
  end

  def variables_params
    (params[:variables].blank? ? {} : params.require(:variables).permit!)
  end
end
