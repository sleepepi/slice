class DesignOptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_editable_project
  before_action :redirect_without_project
  before_action :set_editable_design
  before_action :redirect_without_design

  before_action :set_design_option,               only: [ :show, :edit, :update, :destroy ]
  before_action :redirect_without_design_option,  only: [ :show, :edit, :update, :destroy ]


  def new_section
    @design_option = @design.design_options.new(design_option_params)
    @section = @design.sections.new
  end

  def new_variable
    @design_option = @design.design_options.new(design_option_params)
    @variable = @project.variables.new(variable_params)
  end

  # def new

  # end

  def edit

  end

  def create_section
    @section = @design.sections.new(section_params)
    @section.project_id = @project.id
    @section.user_id = current_user.id
    @design_option = @design.design_options.new(design_option_params)
    if @section.save
      @design_option.section_id = @section.id
      @design_option.save
    end
    if !@section.new_record? and !@design_option.new_record?
      @design.insert_new_design_option!(@design_option)
      render :index
    else
      render :new_section
    end
  end

  def create_variable
    @variable = @design.dbvariables.new(variable_params)
    @variable.project_id = @project.id
    @variable.user_id = current_user.id
    @design_option = @design.design_options.new(design_option_params)
    if @variable.save
      if @variable.variable_type == 'grid' and not params[:questions].blank?
        variable.create_variables_from_questions!(params[:questions])
      end
      @design_option.variable_id = @variable.id
      @design_option.save
    end
    if !@variable.new_record? and !@design_option.new_record?
      @design.insert_new_design_option!(@design_option)
      render :index
    else
      render :new_variable
    end
  end

  # def create
  #   position = design_option_params[:position]

  #   @design_option = @design.design_options.new(design_option_params)

  #   if @design_option.save
  #     @design.design_options.where('position >= ?', @design_option.position).each{ |design_option| design_option.update(position: design_option.position + 1) }
  #     @design_option.update position: design_option_params[:position]

  #     # Section
  #     # Variable

  #   else

  #   end


  # end

  def update
    if @design_option.update(design_option_params) and ((@design_option.section and @design_option.section.update(section_params)) or (@design_option.variable and @design_option.variable.update(variable_params)))
      render :show
    else
      render :edit
    end
  end


  def destroy
    @design_option.destroy
    @design.recalculate_design_option_positions!
    @design.reload
    render :index
  end

  def update_section_order
    section_order = params[:sections].to_s.split(',').collect{ |a| a.to_i }
    @design.reorder_sections(section_order, current_user)
    render 'update_order'
  end

  def update_option_order
    row_order = params[:rows].to_s.split(',').collect{ |a| a.to_i }
    @design.reorder_options(row_order, current_user)
    render 'update_order'
  end

  def reorder
  end

  private

    def set_editable_design
      @design = @project.designs.find_by_id(params[:design_id])
    end

    def redirect_without_design
      empty_response_or_root_path(project_designs_path(@project)) unless @design
    end

    def set_design_option
      @design_option = @design.design_options.find_by_id params[:id]
    end

    def redirect_without_design_option
      empty_response_or_root_path(project_design_path(@project, @design)) unless @design_option
    end

    def design_option_params
      params.require(:design_option).permit(
        :variable_id, :section_id, :position, :required, :branching_logic
      )
    end

    def section_params
      params.require(:section).permit(
        :name, :description, :sub_section,
        :image, :image_cache, :remove_image
      )
    end

    def variable_params
      params.require(:variable).permit(
        :name, :display_name, :variable_type #, :description, :display_name_visibility, :prepend, :append
      )
    end

end
