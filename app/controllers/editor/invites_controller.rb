# frozen_string_literal: true

# Allows project editors to invite users to project, sites, and AE teams.
class Editor::InvitesController < Editor::EditorController
  before_action :find_invite_or_redirect, only: [:show, :destroy]
  before_action :find_editable_invite_or_redirect, only: [:edit, :update]

  layout "layouts/full_page_sidebar_dark"

  # GET /editor/projects/:project_id/invites
  def index
    scope = @project.invites.search_any_order(params[:search])
    @invites = scope_order(scope).page(params[:page]).per(20)
  end

  # GET /editor/projects/:project_id/invites/new
  def new
    @invite = @project.invites.new(role_level: "project", email: params[:email])
  end

  # POST /editor/projects/:project_id/invites
  def create
    @invite = @project.invites.where(inviter: current_user).new(invite_params)
    if @invite.save
      @invite.send_email_in_background!
      redirect_to project_team_path(@project), notice: "Invite was successfully sent."
    else
      render :new
    end
  end

  # # GET /editor/projects/:project_id/invites/:id/edit
  # def edit
  # end

  # PATCH /editor/projects/:project_id/invites/:id
  def update
    if @invite.update(invite_params)
      redirect_to project_team_path(@project), notice: "Invite was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /editor/projects/:project_id/invites/:id
  def destroy
    email = @invite.email
    @project = @invite.project

    @invite.destroy

    respond_to do |format|
      format.html { redirect_to project_team_path(@project), notice: "Invite was successfully deleted." }
      format.js do
        @user = User.current.find_by(email: email)
        render "team/pending_invites"
      end
    end
  end

  private

  def find_invite_or_redirect
    @invite = @project.invites.find_by(id: params[:id])
    empty_response_or_root_path(project_team_path(@project)) unless @invite
  end

  def find_editable_invite_or_redirect
    @invite = @project.invites.where(accepted_at: nil, declined_at: nil).find_by(id: params[:id])
    empty_response_or_root_path(project_team_path(@project)) unless @invite
  end

  def invite_params
    params.require(:invite).permit(
      :email, :role, :subgroup_type, :subgroup_id,
      # For selection and filtering of roles.
      :role_level
    )
  end

  def scope_order(scope)
    @order = params[:order]
    scope.order(Arel.sql(Invite::ORDERS[params[:order]] || Invite::DEFAULT_ORDER))
  end
end
