# frozen_string_literal: true

# Allows project editors to create and update project forms.
class Editor::SformsController < Editor::EditorController
  before_action :find_sform_or_redirect, only: [:show, :edit, :update, :destroy, :builder, :save_object, :remove_object]

  layout "layouts/full_page"

  # GET /editor/projects/1/forms
  def index
    @sforms = @project.checks.order(:archived, :name).page(params[:page]).per(40)
  end

  # POST /editor/projects/1/forms/1/builder/save-object.json
  def save_object
    @design_option = @sform.design_options.find_by(id: params[:design_option_id])
    if @design_option
      if @design_option.variable
        @design_option.variable.update(display_name: params[:display_name])
      elsif @design_option.section
        @design_option.section.update(name: params[:display_name])
      else
        create_new_variable(@design_option, params[:display_name])
      end
    else
      @design_option = @sform.design_options.create()
      create_new_variable(@design_option, params[:display_name])
    end
  end

  # POST /editor/projects/1/forms/1/builder/remove-object.json
  def remove_object
    @design_option = @sform.design_options.find_by(id: params[:design_option_id])
    @design_option.destroy
  end

  # # GET /editor/projects/1/forms/1/builder
  # # GET /editor/projects/1/forms/1/builder.js
  # def builder
  # end

  private

  def editable_sforms
    current_user.all_designs.where(project: @project)
  end

  def find_sform_or_redirect
    @sform = editable_sforms.find_by_param(params[:id])
    empty_response_or_root_path(project_designs_path(@project)) unless @sform
  end

  def create_new_variable(design_option, display_name)
    variable = @project.variables.create(
      name: create_variable_name(params[:display_name]),
      display_name: params[:display_name],
      variable_type: "string"
    )
    design_option.update(variable: variable)
  end

  def create_variable_name(display_name)
    display_name
      .downcase
      .gsub(/[^a-z]/, " ")
      .squish
      .split(" ")
      .select { |b| b.size > 1 && !b.in?(%w(and the it but of)) }
      .join("_").first(16) + "#{SecureRandom.hex(8)}"
  end
end
