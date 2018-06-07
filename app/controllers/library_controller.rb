# frozen_string_literal: true

# Provides access to user created Slice forms.
class LibraryController < ApplicationController
  before_action :find_profile_or_redirect, only: [:profile, :members]
  before_action :find_tray_or_redirect, only: [:tray, :print]

  layout "layouts/full_page"

  # GET /library
  def index
    search = []
    author = ""
    params[:search].to_s.squish.split(" ").each do |token|
      if token.match(/^author\:/)
        author = token.gsub(/^author\:/, "")
      else
        search << token
      end
    end

    @trays = Tray.search(search.join(" "), match_start: false).order(:name).page(params[:page]).per(20)
  end

  # # GET /library/:username/:id
  # # GET /library/:username/:id.json
  # def tray
  # end

  # GET /library/:username/:id.pdf
  def print
    tray_print = @tray.tray_prints.where(language: World.language).first_or_create
    tray_print.regenerate! if tray_print.regenerate?
    send_file_if_present tray_print.file, type: "application/pdf", disposition: "inline"
  end

  # GET /libary/:username
  def profile
    @trays = @profile.trays.search(params[:search], match_start: false).order(:name).page(params[:page]).per(20)
  end

  # GET /orgs/:username/members
  def members
    redirect_to library_profile_path unless @profile.organization
    @members = @profile.organization.members.order(:full_name).page(params[:page]).per(20)
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

  def find_profile_or_redirect
    @profile = Profile.find_by_param(params[:username])
    empty_response_or_root_path(library_root_path) unless @profile
  end

  def find_tray_or_redirect
    @profile = Profile.find_by_param(params[:username])
    @tray = @profile.trays.find_by(slug: params[:id]) if @profile
    empty_response_or_root_path(library_root_path) unless @tray
  end

  def find_member
    @member = User.current.find_by(id: params[:id])
  end
end
