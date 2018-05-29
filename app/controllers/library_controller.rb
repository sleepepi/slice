# frozen_string_literal: true

# Provides access to user created Slice forms.
class LibraryController < ApplicationController
  before_action :find_profile_or_redirect, only: :profile
  before_action :find_tray_or_redirect, only: [:tray, :print]

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
    render layout: "layouts/full_page"
  end

  # GET /library/:username/:id
  # GET /library/:username/:id.json
  def tray
    render layout: "layouts/full_page"
  end

  # GET /library/:username/:id.pdf
  def print
    file_pdf_location = @tray.latex_file_location
    if File.exist?(file_pdf_location)
      send_file file_pdf_location, filename: "#{@tray.profile.username}_#{@tray.slug}#{"_#{World.language}" if World.translate_language?}.pdf", type: "application/pdf", disposition: "inline"
    else
      redirect_to tray_path(@tray.profile, @tray), alert: "Failed to generate PDF."
    end
  end

  # GET /libary/:username
  def profile
    @trays = @profile.trays.search(params[:search], match_start: false).order(:name).page(params[:page]).per(20)
    render layout: "layouts/full_page"
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
