class MembersController < ApplicationController
  before_action :authenticate_user!
  before_action :find_member, only: :profile_picture

  # GET /members/:id
  def show
    redirect_to root_path
  end

  # GET /members/:id/profile_picture
  def profile_picture
    if @member&.profile_picture&.thumb.present?
      send_file(@member&.profile_picture&.thumb&.path)
    else
      file_path = Rails.root.join("app", "assets", "images", "members", "member-secret.png")
      File.open(file_path, "r") do |f|
        send_data f.read, type: "image/png", filename: "member.png"
      end
    end
  end

  private

  def find_member
    @member = User.current.find_by(id: params[:id])
  end
end
