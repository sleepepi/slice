class AeModule::BaseController < ApplicationController
  before_action :authenticate_user!

  private

  def adverse_events
    ae_ids = []
    ae_ids += @project.ae_adverse_events.pluck(:id) if @project.ae_admin?(current_user)
    ae_ids += current_user.all_ae_adverse_events.where(project: @project) if @project.ae_reporter?(current_user)
    if @project.ae_team_manager?(current_user)
      team_ids = @project.ae_review_team_members.where(user: current_user, manager: true).pluck(:ae_review_team_id)
      ae_ids += @project.ae_adverse_event_review_teams.where(ae_review_team_id: team_ids).pluck(:ae_adverse_event_id)
    end
    if @project.ae_team_principal_reviewer?(current_user)
      team_ids = @project.ae_review_team_members.where(user: current_user, principal_reviewer: true).pluck(:ae_review_team_id)
      ae_ids += @project.ae_adverse_event_review_teams.where(ae_review_team_id: team_ids).pluck(:ae_adverse_event_id)
    end
    if @project.ae_team_reviewer?(current_user)
      team_ids = @project.ae_review_team_members.where(user: current_user, reviewer: true).pluck(:ae_review_team_id)
      ae_ids += @project.ae_adverse_event_review_teams.where(ae_review_team_id: team_ids).pluck(:ae_adverse_event_id)
    end
    if @project.ae_team_viewer?(current_user)
      team_ids = @project.ae_review_team_members.where(user: current_user, viewer: true).pluck(:ae_review_team_id)
      ae_ids += @project.ae_adverse_event_review_teams.where(ae_review_team_id: team_ids).pluck(:ae_adverse_event_id)
    end
    @project.ae_adverse_events.where(id: ae_ids)
  end

  def find_adverse_event_or_redirect(id = :adverse_event_id)
    @adverse_event = adverse_events.find_by(id: params[id])
    @subject = @adverse_event&.subject
    @roles = @adverse_event.roles(current_user)
    empty_response_or_root_path(ae_module_adverse_events_path(@project)) unless @adverse_event
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
