class RandomizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_editable_project
  before_action :redirect_without_project
  before_action :set_randomization,                only: [:show, :undo, :destroy]
  before_action :redirect_without_randomization,   only: [:show, :undo, :destroy]

  # GET /randomizations
  # GET /randomizations.json
  def index
    @randomizations = @project.randomizations.includes(:subject).order("randomized_at DESC NULLS LAST").page(params[:page]).per(40)
  end

  # GET /randomizations/1
  # GET /randomizations/1.json
  def show
  end

  # PATCH /randomizations/1/undo
  # PATCH /randomizations/1/undo.json
  def undo
    @randomization.update(subject_id: nil, randomized_at: nil, randomized_by_id: nil, attested: false)
    respond_to do |format|
      format.html { redirect_to project_randomizations_path(@project), notice: 'Randomization was successfully removed.' }
      format.json { render :show, status: :ok, location: @randomization }
    end
  end

  # # DELETE /randomizations/1
  # # DELETE /randomizations/1.json
  # def destroy
  #   @randomization.destroy
  #   respond_to do |format|
  #     format.html { redirect_to project_randomizations_path(@project), notice: 'Randomization was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

  private
    def set_randomization
      @randomization = @project.randomizations.find_by_id(params[:id])
    end

    def redirect_without_randomization
      empty_response_or_root_path(project_randomizations_path(@project)) unless @randomization
    end
end
