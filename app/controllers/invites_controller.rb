# frozen_string_literal: true

# Allows users to accept or decline invites to other projects.
class InvitesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_invite_or_redirect, only: [:show, :accept, :decline]

  # GET /invites
  def index
    # @invites = current_user.current_invites.page(params[:page]).per(20)
    redirect_to dashboard_path
  end

  # # GET /invites/:id
  # def show
  # end

  # POST /invites/:id/accept
  def accept
    @invite.accept!(current_user)
    respond_to do |format|
      format.html { redirect_to @invite.project }
      format.js { render :show }
    end
  end

  # POST /invites/:id/decline
  def decline
    @invite.decline!
    respond_to do |format|
      format.html { redirect_to dashboard_path }
      format.js { render :show }
    end
  end

  private

  def find_invite_or_redirect
    @invite = current_user.invites.find_by(id: params[:id])
    empty_response_or_root_path(dashboard_path) unless @invite
  end
end
