class SiteUsersController < ApplicationController
  before_action :authenticate_user!

  # POST /site_users/1.js
  def resend
    @site_user = SiteUser.current.find_by_id(params[:id])
    @site = current_user.all_sites.find_by_id(@site_user.site_id) if @site_user

    if @site and @site_user
      @site_user.send_invitation
      # resend.js.erb
    else
      render nothing: true
    end
  end

  def accept
    @site_user = SiteUser.find_by_invite_token(params[:invite_token])
    if @site_user and @site_user.user == current_user
      redirect_to [@site_user.site.project, @site_user.site], notice: "You have already been added to #{@site_user.site.name}."
    elsif @site_user and @site_user.user
      redirect_to root_path, alert: "This invite has already been claimed."
    elsif @site_user
      @site_user.update_attributes user_id: current_user.id
      redirect_to [@site_user.project, @site_user.site], notice: "You have been successfully been added to the site."
    else
      redirect_to root_path, alert: 'Invalid invitation token.'
    end
  end

  # DELETE /site_users/1
  # DELETE /site_users/1.json
  def destroy
    @site_user = SiteUser.current.find_by_id(params[:id])
    @site = current_user.all_sites.find_by_id(@site_user.site_id) if @site_user
    @project = @site_user.project if @site_user

    respond_to do |format|
      if @site and @project
        @site_user.destroy
        format.html { redirect_to [@site.project, @site] }
        format.json { head :no_content }
        format.js { render 'projects/members' }
      elsif @site_user.user == current_user and @project
        @site = @site_user.site
        @site_user.destroy
        format.html { redirect_to root_path }
        format.json { head :no_content }
        format.js { render 'projects/members' }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
        format.js { render nothing: true }
      end
    end
  end
end
