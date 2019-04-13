# frozen_string_literal: true

# Allows users to view public profiles and edit their own profile or their
# organizations profile.
class ProfilesController < ApplicationController
  before_action :authenticate_user!, only: [
    :new, :create, :edit, :update, :destroy
  ]
  before_action :find_viewable_profile_or_redirect, only: [:show, :picture]
  before_action :find_editable_profile_or_redirect, only: [
    :edit, :update, :destroy
  ]

  # GET /profiles
  def index
    @profiles = Profile.all
  end

  # GET /profiles/1
  def show
  end

  # GET /profiles/new
  def new
    redirect_to edit_profile_url(current_user.profile) if current_user.profile
    @profile = Profile.new
  end

  # GET /profiles/1/edit
  def edit
  end

  # POST /profiles
  def create
    @profile = Profile.where(user: current_user).new(profile_params)
    if @profile.save
      redirect_to library_profile_path(@profile), notice: "Profile was successfully created."
    else
      render :new
    end
  end

  # PATCH /profiles/1
  def update
    if @profile.update(profile_params)
      redirect_to library_profile_path(@profile), notice: "Profile was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /profiles/1
  def destroy
    @profile.destroy
    redirect_to profiles_path, notice: "Profile was successfully deleted."
  end

  # GET /profiles/:id/picture
  def picture
    send_profile_picture_if_present(@profile&.object, thumb: true)
  end

  private

  def find_viewable_profile_or_redirect
    @profile = Profile.find_by_param(params[:id])
    redirect_without_profile unless @profile
  end

  def find_editable_profile_or_redirect
    @profile = current_user.profiles.find_by_param(params[:id])
    redirect_without_profile unless @profile
  end

  def redirect_without_profile
    empty_response_or_root_path(library_root_path) unless @profile
  end

  def profile_params
    params.require(:profile).permit(:username, :description)
  end
end
