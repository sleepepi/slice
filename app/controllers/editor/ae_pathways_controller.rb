# frozen_string_literal: true

# Allows project editors to create and update team pathways.
class Editor::AePathwaysController < Editor::EditorController
  before_action :find_team_or_redirect
  before_action :find_pathway_or_redirect, only: [:show, :edit, :update, :destroy]

  layout "layouts/full_page_sidebar_dark"

  # GET /editor/projects/:project_id/ae-module/teams/:team_id/pathways
  def index
    scope = @team.ae_team_pathways.search_any_order(params[:search])
    @pathways = scope_order(scope).page(params[:page]).per(20)
  end

  # # GET /editor/projects/:project_id/ae-module/teams/:team_id/pathways/:id
  # def show
  # end

  # GET /editor/projects/:project_id/ae-module/teams/:team_id/pathways/new
  def new
    @pathway = @team.ae_team_pathways.new
  end

  # # GET /editor/projects/:project_id/ae-module/teams/:team_id/pathways/:id/edit
  # def edit
  # end

  # POST /editor/projects/:project_id/ae-module/teams/:team_id/pathways
  def create
    @pathway = @project.ae_team_pathways.where(ae_team: @team).new(pathway_params)
    if @pathway.save
      redirect_to editor_project_ae_team_ae_pathway_path(
        @project, @team, @pathway
      ), notice: "Pathway was successfully created."
    else
      render :new
    end
  end

  # PATCH /editor/projects/:project_id/ae-module/teams/:team_id/pathways/:id
  def update
    if @pathway.update(pathway_params)
      redirect_to editor_project_ae_team_ae_pathway_path(
        @project, @team, @pathway
      ), notice: "Pathway was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /editor/projects/:project_id/ae-module/teams/:team_id/pathways/1
  def destroy
    @pathway.destroy
    redirect_to editor_project_ae_team_ae_pathways_path(@project, @team),
                notice: "Pathway was successfully deleted."
  end

  private

  def find_pathway_or_redirect
    @pathway = @team.ae_team_pathways.find_by(id: params[:id])
    empty_response_or_root_path(editor_project_ae_team_path(@project, @team)) unless @pathway
  end

  def pathway_params
    params.require(:ae_team_pathway).permit(:name)
  end

  def scope_order(scope)
    @order = params[:order]
    scope.order(Arel.sql(AeTeamPathway::ORDERS[params[:order]] || AeTeamPathway::DEFAULT_ORDER))
  end
end
