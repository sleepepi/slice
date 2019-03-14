# frozen_string_literal: true

# Allows project editors to modify medication names.
class Editor::MedicationTemplatesController < Editor::EditorController
  layout "layouts/full_page_sidebar_dark"

  # GET /editor/projects/:project_id/medications/showall
  def showall
    @medication_templates = @project.medication_templates
  end

  # GET /editor/projects/:project_id/medications/editall
  def editall
    @medication_templates = @project.medication_templates
  end

  # POST /editor/projects/:project_id/medications/editall
  def updateall
    if params.key?(:medication_names)
      @project.medication_templates.update_all(mark_for_deletion: true)
      (params[:medication_names] || "").split("\n").collect(&:squish).sort_by(&:downcase).each do |medication_name|
        template = @project.medication_templates.where("name ILIKE ?", medication_name).first_or_create
        template.update(name: medication_name, mark_for_deletion: false)
      end
      @project.medication_templates.where(mark_for_deletion: true).destroy_all
      redirect_to showall_editor_project_medication_templates_path(@project)
    else
      render :editall
    end
  end
end
