# frozen_string_literal: true

# Allows users to accept or decline invites to other projects.
class InvitesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_invite_or_redirect, only: [:show, :accept, :decline]

  # GET /invites
  def index
    @invites = current_user.invites.page(params[:page]).per(20)
  end

  # # GET /invites/:id
  # def show
  # end

  # POST /invites/:id/accept
  def accept
    @invite.accept!(current_user)
    respond_to do |format|
      format.html { redirect_to @invite.project }
      format.js { render :index }
    end
  end

  # POST /invites/:id/decline
  def decline
    @invite.decline!
    respond_to do |format|
      format.html { redirect_to invites_path }
      format.js { render :index }
    end
  end

  private

  def find_invite_or_redirect
    @invite = current_user.invites.find_by(id: params[:id])
    empty_response_or_root_path(invites_path) unless @invite
  end
end
