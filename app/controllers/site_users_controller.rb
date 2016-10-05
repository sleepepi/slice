# frozen_string_literal: true

# Allows members to invite others to collaborate on a project as a site member.
class SiteUsersController < ApplicationController
  before_action :authenticate_user!, except: [:invite]

  def invite
    session[:site_invite_token] = params[:site_invite_token]
    if current_user
      site_invite_token = session[:site_invite_token]
      @site_user = SiteUser.find_by_invite_token(site_invite_token)
      if @site_user
        redirect_to accept_project_site_users_path(@site_user.project)
      else
        session[:site_invite_token] = nil
        redirect_to root_path, alert: 'Invalid invitation token.'
      end
    else
      redirect_to new_user_session_path
    end
  end

  # POST /site_users/1.js
  def resend
    @site_user = SiteUser.find_by_id(params[:id])
    @site = current_user.all_sites.find_by_id(@site_user.site_id) if @site_user
    if @site && @site_user
      @site_user.send_user_invited_email_in_background!
      @project = @site.project
      render :update
    else
      head :ok
    end
  end

  def accept
    site_invite_token = session.delete(:site_invite_token)
    @site_user = SiteUser.find_by_invite_token(site_invite_token)
    if @site_user && @site_user.user == current_user
      redirect_to [@site_user.site.project, @site_user.site],
                  notice: "You have already been added to #{@site_user.site.name}."
    elsif @site_user && @site_user.user
      redirect_to root_path, alert: 'This invite has already been claimed.'
    elsif @site_user
      @site_user.update_attributes user_id: current_user.id
      redirect_to [@site_user.project, @site_user.site], notice: 'You have been successfully been added to the site.'
    else
      redirect_to root_path, alert: 'Invalid invitation token.'
    end
  end

  # PATCH /site_users/1
  # PATCH /site_users/1.js
  def update
    @project = current_user.all_projects.find_by_param params[:project_id]
    @site_user = @project.site_users.find_by_id params[:id] if @project
    if @project && @project.editable_by?(current_user) && @project.blinding_enabled? && @project.unblinded?(current_user) && @site_user
      @site_user.update unblinded: (params[:unblinded] == '1')
      flash_notice = "Set member as #{@site_user.unblinded? ? 'un' : ''}blinded."
    end
    respond_to do |format|
      format.html { redirect_to @project ? team_project_path(@project) : root_path, notice: flash_notice }
      format.js
    end
  end

  # DELETE /site_users/1
  def destroy
    @site_user = SiteUser.find_by_id(params[:id])
    @site = current_user.all_sites.find_by_id(@site_user.site_id) if @site_user
    @project = @site_user.project if @site_user

    respond_to do |format|
      if @site && @project
        @site_user.destroy
        format.html { redirect_to [@site.project, @site] }
        format.js { render 'projects/members' }
      elsif @site_user.user == current_user && @project
        @site = @site_user.site
        @site_user.destroy
        format.html { redirect_to root_path }
        format.js { render 'projects/members' }
      else
        format.html { redirect_to root_path }
        format.js { head :ok }
      end
    end
  end
end
