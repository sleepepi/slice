class AeModule::BaseController < ApplicationController
  before_action :authenticate_user!

  private

  def adverse_events
    if @project.ae_admin?(current_user)
      @project.ae_adverse_events
    elsif @project.ae_reporter?(current_user)
      current_user.all_ae_adverse_events.where(project: @project)
    else
      AeAdverseEvent.none
    end
  end

  def find_adverse_event_or_redirect(id = :adverse_event_id)
    @adverse_event = adverse_events.find_by(id: params[id])
    @subject = @adverse_event&.subject
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
