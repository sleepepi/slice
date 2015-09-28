class RandomizationsController < ApplicationController
  before_action :authenticate_user!

  before_action :set_viewable_project,                  only: [:index, :show]
  before_action :set_editable_project_or_editable_site, only: [:choose_scheme, :undo]
  before_action :redirect_without_project

  before_action :set_viewable_randomization,            only: [:show]
  before_action :set_editable_randomization,            only: [:undo] # , :destroy
  before_action :redirect_without_randomization,        only: [:show, :undo] # , :destroy

  def choose_scheme
    if @project.randomization_schemes.published.count == 1
      redirect_to randomize_subject_to_list_project_randomization_scheme_path(@project, @project.randomization_schemes.published.first)
    end
  end

  # GET /randomizations
  # GET /randomizations.json
  def index
    @randomizations = current_user.all_viewable_randomizations.where(project_id: @project.id).includes(:subject).order("randomized_at DESC NULLS LAST").page(params[:page]).per(40)
  end

  # GET /randomizations/1
  # GET /randomizations/1.json
  def show
  end

  # PATCH /randomizations/1/undo
  # PATCH /randomizations/1/undo.json
  def undo
    @randomization.undo!
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

  def set_viewable_randomization
    @randomization = current_user.all_viewable_randomizations.find_by_id(params[:id])
  end

  def set_editable_randomization
    @randomization = current_user.all_randomizations.find_by_id(params[:id])
  end

  def redirect_without_randomization
    empty_response_or_root_path(project_randomizations_path(@project)) unless @randomization
  end
end
