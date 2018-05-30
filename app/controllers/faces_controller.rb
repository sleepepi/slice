class FacesController < ApplicationController
  before_action :find_profile_or_redirect
  before_action :find_tray_or_redirect
  before_action :find_cube_or_redirect
  before_action :find_face_or_redirect, only: [:show, :edit, :update, :destroy]

  # GET /faces
  # GET /faces.json
  def index
    @faces = @cube.faces
  end

  # # GET /faces/1
  # # GET /faces/1.json
  # def show
  # end

  # GET /faces/new
  def new
    @face = @cube.faces.new
  end

  # # GET /faces/1/edit
  # def edit
  # end

  # POST /faces
  # POST /faces.json
  def create
    @face = @cube.faces.new(face_params)
    respond_to do |format|
      if @face.save
        url = tray_cube_face_path(@face.cube.tray.profile, @face.cube.tray, @face.cube, @face)
        format.html { redirect_to url, notice: "Face was successfully created." }
        format.json { render :show, status: :created, location: url }
      else
        format.html { render :new }
        format.json { render json: @face.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH /faces/1
  # PATCH /faces/1.json
  def update
    respond_to do |format|
      if @face.update(face_params)
        url = tray_cube_face_path(@face.cube.tray.profile, @face.cube.tray, @face.cube, @face)
        format.html { redirect_to url, notice: "Face was successfully updated." }
        format.json { render :show, status: :ok, location: url }
      else
        format.html { render :edit }
        format.json { render json: @face.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /faces/positions.json
  def positions
    @faces = @cube.faces.where(id: params[:faces].keys)
    ActiveRecord::Base.transaction do
      @faces.each do |face|
        face.update position: params[:faces].dig(face.id.to_s, :position)
      end
    end
    render :index
  end

  # DELETE /faces/1
  # DELETE /faces/1.json
  def destroy
    @face.destroy
    respond_to do |format|
      format.html { redirect_to tray_cube_faces_path(@face.cube.tray.profile, @face.cube.tray, @face.cube), notice: "Face was successfully deleted." }
      format.json { head :no_content }
    end
  end

  private

  def find_profile_or_redirect
    @profile = current_user.profiles.find_by_param(params[:username])
    empty_response_or_root_path(library_root_path) unless @profile
  end

  def find_tray_or_redirect
    @tray = @profile.trays.find_by_param(params[:tray_id])
    empty_response_or_root_path(library_profile_path(@profile)) unless @tray
  end

  def find_cube_or_redirect
    @cube = @tray.cubes.find_by(id: params[:cube_id])
    empty_response_or_root_path(tray_cubes_path(@tray.profile, @tray)) unless @cube
  end

  def find_face_or_redirect
    @face = @cube.faces.find_by(id: params[:id])
    empty_response_or_root_path(tray_cube_path(@tray.profile, @tray, @cube)) unless @face
  end

  def face_params
    params.require(:face).permit(:position, :text)
  end
end
