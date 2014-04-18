class SectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_project,      only: [ :image ]
  before_action :redirect_without_project,  only: [ :image ]
  before_action :set_viewable_design,       only: [ :image ]
  before_action :redirect_without_design,   only: [ :image ]
  before_action :set_section,               only: [ :image ]
  before_action :redirect_without_section,  only: [ :image ]

  def image
    send_file File.join( CarrierWave::Uploader::Base.root, @section.image.url )
  end

  # # GET /sections
  # # GET /sections.json
  # def index
  #   @sections = Section.all
  # end

  # # GET /sections/1
  # # GET /sections/1.json
  # def show
  # end

  # # GET /sections/new
  # def new
  #   @section = Section.new
  # end

  # # GET /sections/1/edit
  # def edit
  # end

  # # POST /sections
  # # POST /sections.json
  # def create
  #   @section = Section.new(section_params)

  #   respond_to do |format|
  #     if @section.save
  #       format.html { redirect_to @section, notice: 'Section was successfully created.' }
  #       format.json { render :show, status: :created, location: @section }
  #     else
  #       format.html { render :new }
  #       format.json { render json: @section.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # PATCH/PUT /sections/1
  # # PATCH/PUT /sections/1.json
  # def update
  #   respond_to do |format|
  #     if @section.update(section_params)
  #       format.html { redirect_to @section, notice: 'Section was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @section }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @section.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # DELETE /sections/1
  # # DELETE /sections/1.json
  # def destroy
  #   @section.destroy
  #   respond_to do |format|
  #     format.html { redirect_to sections_url }
  #     format.json { head :no_content }
  #   end
  # end

  private

    def set_section
      @section = @design.sections.find_by_id(params[:id])
    end

    def redirect_without_section
      empty_response_or_root_path(project_design_path(@project, @design)) unless @section
    end

    def set_viewable_design
      @design = current_user.all_viewable_designs.find_by_id(params[:design_id])
    end

    def redirect_without_design
      empty_response_or_root_path(project_designs_path(@project)) unless @design
    end


  #   # Use callbacks to share common setup or constraints between actions.
  #   def set_section
  #     @section = Section.find(params[:id])
  #   end

  #   # Never trust parameters from the scary internet, only allow the white list through.
  #   def section_params
  #     params[:section]
  #   end
end
