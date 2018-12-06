class AeModule::BaseController < ApplicationController
  before_action :authenticate_user!

  private

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
