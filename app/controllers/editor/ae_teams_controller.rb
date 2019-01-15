# frozen_string_literal: true

# Allows project editors to create and update adverse event teams.
class Editor::AeTeamsController < Editor::EditorController
  before_action :find_team_or_redirect, only: [
    :show, :edit, :update, :destroy
  ]

  layout "layouts/full_page_sidebar_dark"

  # GET /editor/projects/:project_id/ae-modules/teams
  def index
    @teams = @project.ae_teams.order(:name).page(params[:page]).per(40)
  end

  # # GET /editor/projects/:project_id/ae-modules/teams/:id
  # def show
  # end

  # GET /editor/projects/:project_id/ae-modules/teams/new
  def new
    @team = @project.ae_teams.new
  end

  # # GET /editor/projects/:project_id/ae-modules/teams/:id/edit
  # def edit
  # end

  # POST /editor/projects/:project_id/ae-modules/teams
  def create
    @team = @project.ae_teams.new(team_params)
    if @team.save
      redirect_to editor_project_ae_team_path(@project, @team), notice: "Team was successfully created."
    else
      render :new
    end
  end

  # PATCH /editor/projects/:project_id/ae-modules/teams/:id
  # PATCH /editor/projects/:project_id/ae-modules/teams/:id.js
  def update
    if @team.update(team_params)
      respond_to do |format|
        format.html do
          redirect_to editor_project_ae_team_path(@project, @team), notice: "Team was successfully updated."
        end
        format.js
      end
    else
      render :edit
    end
  end

  # DELETE /editor/projects/:project_id/ae-modules/teams/:id
  # DELETE /editor/projects/:project_id/ae-modules/teams/:id.js
  def destroy
    @team.destroy
    respond_to do |format|
      format.html { redirect_to editor_project_ae_teams_path(@project), notice: "Team was successfully deleted." }
      format.js
    end
  end

  private

  def find_team_or_redirect
    @team = @project.ae_teams.find_by_param(params[:id])
    redirect_without_team
  end

  def redirect_without_team
    empty_response_or_root_path(editor_project_ae_teams_path(@project)) unless @team
  end

  def team_params
    params.require(:ae_team).permit(
      :name, :slug, :short_name
    )
  end
end
