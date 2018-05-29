# frozen_string_literal: true

# Creates trays which are templates for slice forms.
class TraysController < ApplicationController
  before_action :authenticate_user!
  before_action :find_profile_or_redirect
  before_action :find_tray_or_redirect, only: [:show, :edit, :update, :destroy]

  # GET /trays
  # GET /trays.json
  def index
    @trays = Tray.all
  end

  # GET /trays/1
  # GET /trays/1.json
  def show
    render layout: "layouts/full_page"
  end

  # GET /trays/new
  def new
    @tray = @profile.trays.new
  end

  # # GET /trays/1/edit
  # def edit
  # end

  # POST /trays
  # POST /trays.json
  def create
    @tray = @profile.trays.new(tray_params)

    respond_to do |format|
      if @tray.save
        format.html { redirect_to library_tray_path(@tray.profile, @tray), notice: "Tray was successfully created." }
        format.json { render :show, status: :created, location: @tray }
      else
        format.html { render :new }
        format.json { render json: @tray.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH /trays/1
  # PATCH /trays/1.json
  def update
    respond_to do |format|
      if @tray.update(tray_params)
        format.html { redirect_to library_tray_path(@tray.profile, @tray), notice: "Tray was successfully updated." }
        format.json { render :show, status: :ok, location: @tray }
      else
        format.html { render :edit }
        format.json { render json: @tray.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trays/1
  # DELETE /trays/1.json
  def destroy
    @tray.destroy
    respond_to do |format|
      format.html { redirect_to trays_url, notice: "Tray was successfully deleted." }
      format.json { head :no_content }
    end
  end

  private

  def find_profile_or_redirect
    @profile = current_user.profile
    empty_response_or_root_path(library_root_path) unless @profile
  end

  def find_tray_or_redirect
    @tray = @profile.trays.find_by_param(params[:id])
    empty_response_or_root_path(library_profile_path(@profile)) unless @tray
  end

  def tray_params
    params.require(:tray).permit(:name, :slug, :description, :time_in_seconds, :keywords)
  end
end
