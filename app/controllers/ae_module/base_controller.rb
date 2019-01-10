class AeModule::BaseController < ApplicationController
  before_action :authenticate_user!

  private

  def find_project_as_reporter_or_admin_or_team_member_or_redirect
    project = Project.current.find_by_param(params[:project_id])
    if project.ae_reporter?(current_user)
      @project = project
    elsif project.ae_admin?(current_user)
      @project = project
    elsif project.ae_team?(current_user)
      @project = project
    else
      redirect_without_project
    end
  end

  def find_adverse_event_or_redirect(id = :adverse_event_id)
    @adverse_event = adverse_events.find_by(id: params[id])
    if @adverse_event
      @subject = @adverse_event.subject
      set_roles
    else
      empty_response_or_root_path(ae_module_adverse_events_path(@project))
    end
  end

  def adverse_events
    ae_ids = []
    ae_ids += @project.ae_adverse_events.pluck(:id) if @project.ae_admin?(current_user)
    ae_ids += current_user.all_ae_adverse_events.where(project: @project) if @project.ae_reporter?(current_user)
    if @project.ae_team_manager?(current_user)
      team_ids = @project.ae_team_members.where(user: current_user, manager: true).pluck(:ae_team_id)
      ae_ids += @project.ae_adverse_event_teams.where(ae_team_id: team_ids).pluck(:ae_adverse_event_id)
    end
    if @project.ae_team_principal_reviewer?(current_user)
      team_ids = @project.ae_team_members.where(user: current_user, principal_reviewer: true).pluck(:ae_team_id)
      ae_ids += @project.ae_adverse_event_teams.where(ae_team_id: team_ids).pluck(:ae_adverse_event_id)
    end
    if @project.ae_team_reviewer?(current_user)
      team_ids = @project.ae_team_members.where(user: current_user, reviewer: true).pluck(:ae_team_id)
      ae_ids += @project.ae_adverse_event_teams.where(ae_team_id: team_ids).pluck(:ae_adverse_event_id)
    end
    if @project.ae_team_viewer?(current_user)
      team_ids = @project.ae_team_members.where(user: current_user, viewer: true).pluck(:ae_team_id)
      ae_ids += @project.ae_adverse_event_teams.where(ae_team_id: team_ids).pluck(:ae_adverse_event_id)
    end
    @project.ae_adverse_events.where(id: ae_ids)
  end

  def set_roles
    @roles = @adverse_event.roles(current_user)
    @role_reporter = @roles.count { |role, _| role == "reporter" }.positive?
    @role_admin = @roles.count { |role, _| role == "admin" }.positive?
    @role_manager = @roles.count { |role, _| role == "manager" }.positive?
    @role_principal_reviewer = @roles.count { |role, _| role == "principal_reviewer" }.positive?
    @role_reviewer = @roles.count { |role, _| role == "reviewer" }.positive?
  end

  def sheet_params
    params[:sheet] ||= {}
    params[:sheet][:last_user_id] = current_user.id
    params[:sheet][:last_edited_at] = Time.zone.now
    params.require(:sheet).permit(
      :design_id, :variable_ids, :last_user_id, :last_edited_at,
      :subject_event_id, :adverse_event_id, :ae_adverse_event_id, :missing
    )
  end

  def variables_params
    (params[:variables].blank? ? {} : params.require(:variables).permit!)
  end
end
