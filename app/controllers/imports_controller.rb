# frozen_string_literal: true

# Allows designs to be create via imports. Imports can also include the data
# associated to the designs to create and update existing sheets.
class ImportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_editable_project
  before_action :redirect_without_project
  before_action :set_editable_design, only: [:progress, :edit, :update]

  # def index
  # end

  # GET /designs/1/imports/new
  def new
    @design = @project.designs.new
    @variables = []
  end

  # Essentially a type of show action
  # POST /designs/1/imports/progress.js
  def progress
  end

  # GET /designs/1/imports/edit
  def edit
    @design.remove_csv_file!
    @variables = []
  end

  def create
    @design = current_user.designs.where(project_id: @project.id, total_rows: 1).new(design_params)
    if params[:variables].blank?
      @variables = @design.load_variables
      @design.errors.add(:csv_file, 'must be selected') if @design.csv_file.blank?
      @design.name_from_csv!
      render :new
    elsif @design.save
      @design.create_variables!(params[:variables])
      @design.generate_import_in_background(params[:site_id], current_user, request.remote_ip)
      redirect_to [@design.project, @design]
    else
      @variables = @design.load_variables
      @design.name_from_csv!
      render :new
    end
  end

  # PATCH /designs/1/imports
  def update
    @design.csv_file = params[:design][:csv_file] if params[:design] && !params[:design][:csv_file].blank?
    @design.csv_file_cache = params[:design][:csv_file_cache] if params[:design] && !params[:design][:csv_file_cache].blank?

    if params[:design].blank? || (params[:design][:csv_file].blank? && params[:design][:csv_file_cache].blank?) || !@design.valid?
      @variables = []
      @design.errors.add :csv_file, 'must be selected'
      render :edit
      return
    end

    if params[:variables].blank?
      @variables = @design.load_variables
      render :edit
    else
      @design.save
      @design.update rows_imported: 0, import_started_at: Time.zone.now, import_ended_at: nil
      @design.generate_import_in_background(params[:site_id], current_user, request.remote_ip)
      redirect_to [@design.project, @design]
    end
  end

  def json_new
  end

  def json_create
    json = JSON.parse(params[:json_file].read)
    [json].flatten.each do |design_json|
      @project.create_design_from_json(design_json, current_user)
    end

    redirect_to project_designs_path(@project)
  rescue
    @error = 'JSON File can\'t be blank.'
    render 'json_new'
  end

  private

  def set_editable_design
    @design = current_user.all_designs.where(project_id: @project.id).find_by_param params[:id]
    redirect_without_design
  end

  def redirect_without_design
    empty_response_or_root_path(project_designs_path(@project)) unless @design
  end

  def design_params
    params[:design] ||= { blank: '1' }
    params.require(:design).permit(:name, :csv_file, :csv_file_cache)
  end
end
