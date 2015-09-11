class DesignOptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_editable_project
  before_action :redirect_without_project
  before_action :set_editable_design
  before_action :redirect_without_design

  before_action :set_design_option,               only: [ :show, :edit, :update, :destroy ]
  before_action :redirect_without_design_option,  only: [ :show, :edit, :update, :destroy ]


  def new

  end

  def edit

  end

  def create
    # Section

    # Variable

  end

  def update
    if @design_option.update(design_option_params) and ((@design_option.section and @design_option.section.update(section_params)) or (@design_option.variable and @design_option.variable.update(variable_params)))
      render :show
    else
      render :edit
    end
  end


  def destroy

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
        :name, :display_name #, :description, :variable_type, :display_name_visibility, :prepend, :append
      )
    end

end
