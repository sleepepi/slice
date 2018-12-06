class AeModule::AdminsController < AeModule::BaseController
  before_action :find_review_admin_project_or_redirect
  before_action :find_adverse_event_or_redirect, only: [
    :adverse_event, :request_additional_details,
    :submit_request_additional_details, :assign_team
  ]

  # GET /projects/:project_id/ae-module/admins/inbox
  def inbox
    @adverse_events = @project.ae_adverse_events.order(reported_at: :desc).page(params[:page]).per(20)
  end

  # # GET /projects/:project_id/ae-module/admins/adverse-events/:id
  # def adverse_event
  # end

  # GET /projects/:project_id/ae-module/admins/adverse-events/:id/request-additional-details
  def request_additional_details
    @adverse_event_info_request = @adverse_event.ae_adverse_event_info_requests.new
  end

  # POST /projects/:project_id/ae-module/admins/adverse-events/:id/request-additional-details
  def submit_request_additional_details
    @adverse_event_info_request = @adverse_event.ae_adverse_event_info_requests.where(project: @project, user: current_user).new(info_request_params)
    if @adverse_event_info_request.save
      @adverse_event_info_request.open!(current_user)
      redirect_to ae_module_admins_adverse_event_path(@project, @adverse_event), notice: "Request submitted successfully."
    else
      render :request_additional_details
    end
  end

  # POST /projects/:project_id/ae-module/admins/adverse-events/:id/assign-team
  def assign_team
    team = @project.ae_review_teams.find_by_param(params[:review_team_id])
    if team
      @adverse_event.assign_team!(current_user, team)
      notice = "Team assigned successfully."
    else
      notice = "Unable to assign team."
    end
    redirect_to ae_module_admins_adverse_event_path(@project, @adverse_event), notice: notice
  end

  # # GET /projects/:project_id/ae-module/admins/setup-designs
  # def setup_designs
  # end

  # POST /projects/:project_id/ae-module/admins/submit-designs
  def submit_designs
    # Pathway may be nil.
    @pathway = @project.ae_team_pathways.find_by(id: params[:pathway_id])

    ActiveRecord::Base.transaction do
      @project.ae_designments.where(ae_team_pathway: @pathway, assignment: params[:assignment]).destroy_all
      index = 0
      (params[:design_ids] || []).uniq.each do |design_id|
        design = @project.designs.find_by(id: design_id)
        next unless design

        @project.ae_designments.create(
          design: design,
          position: index,
          assignment: params[:assignment],
          ae_review_team: @pathway&.ae_review_team,
          ae_team_pathway: @pathway
        )
        index += 1
      end
    end
    @designments = @project.ae_designments.where(ae_team_pathway: @pathway, assignment: params[:assignment])
    render :designments
  end

  # DELETE /projects/:project_id/ae-module/admins/remove-designment
  def remove_designment
    designment = @project.ae_designments.find_by(id: params[:designment_id])
    designment.destroy
    @pathway = @project.ae_team_pathways.find_by(id: params[:pathway_id])
    @designments = @project.ae_designments.where(ae_team_pathway: @pathway, assignment: params[:assignment])
    render :designments
  end

  private

  def find_review_admin_project_or_redirect
    @project = Project.current.where(id: AeReviewAdmin.where(user: current_user).select(:project_id)).find_by_param(params[:project_id])
    @project = current_user.all_viewable_and_site_projects.find_by_param(params[:project_id]) unless @project # TODO: Remove
    redirect_without_project
  end

  def find_adverse_event_or_redirect
    @adverse_event = @project.ae_adverse_events.find_by(id: params[:id])
    empty_response_or_root_path(ae_module_admins_inbox_path(@project)) unless @adverse_event
  end

  def info_request_params
    params.require(:ae_adverse_event_info_request).permit(
      :comment
    )
  end
end
