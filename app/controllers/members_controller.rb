class MembersController < ApplicationController
  before_action :authenticate_user!
  before_action :find_member, only: :profile_picture

  # GET /members/:id
  def show
    redirect_to root_path
  end

  # GET /members/:id/profile_picture
  def profile_picture
    send_profile_picture_if_present(@member, thumb: true)
  end

  private

  def find_member
    @member = User.current.find_by(id: params[:id])
  end
end
