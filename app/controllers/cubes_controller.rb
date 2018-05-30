# frozen_string_literal: true

class CubesController < ApplicationController
  before_action :find_profile_or_redirect
  before_action :find_tray_or_redirect
  before_action :find_cube_or_redirect, only: [:show, :edit, :update, :destroy]

  # GET /cubes
  # GET /cubes.json
  def index
    @cubes = @tray.cubes
  end

  # # GET /cubes/1
  # # GET /cubes/1.json
  # def show
  # end

  # GET /cubes/new
  def new
    @cube = @tray.cubes.new
  end

  # # GET /cubes/1/edit
  # def edit
  # end

  # POST /cubes
  # POST /cubes.json
  def create
    @cube = @tray.cubes.new(cube_params)
    respond_to do |format|
      if @cube.save
        format.html { redirect_to tray_cube_path(@cube.tray.profile, @cube.tray, @cube), notice: "Cube was successfully created." }
        format.json { render :show, status: :created, location: [@tray, @cube] }
      else
        format.html { render :new }
        format.json { render json: @cube.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH /cubes/1
  # PATCH /cubes/1.json
  def update
    respond_to do |format|
      if @cube.update(cube_params)
        format.html { redirect_to tray_cube_path(@cube.tray.profile, @cube.tray, @cube), notice: "Cube was successfully updated." }
        format.json { render :show, status: :ok, location: [@tray, @cube] }
      else
        format.html { render :edit }
        format.json { render json: @cube.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /cubes/positions.json
  def positions
    @cubes = @tray.cubes.where(id: params[:cubes].keys)
    ActiveRecord::Base.transaction do
      @cubes.each do |cube|
        cube.update position: params[:cubes].dig(cube.id.to_s, :position)
      end
    end
    render :index
  end

  # DELETE /cubes/1
  # DELETE /cubes/1.json
  def destroy
    @cube.destroy
    respond_to do |format|
      format.html { redirect_to tray_cubes_path(@cube.tray.profile, @cube.tray), notice: "Cube was successfully deleted." }
      format.json { head :no_content }
    end
  end

  # DELETE /trays/1/cubes
  def destroy_all
    @tray.cubes.destroy_all
    redirect_to @tray, notice: "Cubes were successfully deleted."
  end

  private

  def find_profile_or_redirect
    @profile = current_user.profile
    empty_response_or_root_path(library_root_path) unless @profile
  end

  def find_tray_or_redirect
    @tray = @profile.trays.find_by_param(params[:tray_id])
    empty_response_or_root_path(library_profile_path(@profile)) unless @tray
  end

  def find_cube_or_redirect
    @cube = @tray.cubes.find_by(id: params[:id])
    empty_response_or_root_path(@tray) unless @cube
  end

  def cube_params
    params.require(:cube).permit(:text, :description, :cube_type, :position)
  end
end
