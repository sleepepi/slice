# frozen_string_literal: true

class RandomizationsController < ApplicationController
  before_action :authenticate_user!

  before_action :set_viewable_project,                  only: [:index, :show, :schedule]
  before_action :set_editable_project_or_editable_site, only: [:choose_scheme, :undo]
  before_action :redirect_without_project

  before_action :redirect_blinded_users

  before_action :set_viewable_randomization,            only: [:show, :schedule]
  before_action :set_editable_randomization,            only: [:undo]

  def choose_scheme
    if @project.randomization_schemes.published.count == 1
      redirect_to randomize_subject_to_list_project_randomization_scheme_path(@project, @project.randomization_schemes.published.first)
    end
  end

  # GET /randomizations
  def index
    @randomizations = current_user.all_viewable_randomizations
                                  .where(project_id: @project.id)
                                  .includes(:subject)
                                  .order('randomized_at DESC NULLS LAST')
                                  .select('randomizations.*')
                                  .page(params[:page])
                                  .per(40)
  end

  # GET /randomizations/1
  def show
  end

  # GET /randomizations/1/schedule.pdf
  def schedule
    file_pdf_location = @randomization.latex_file_location(current_user)
    if File.exist?(file_pdf_location)
      send_file file_pdf_location, filename: 'schedule.pdf', type: 'application/pdf', disposition: 'inline'
    else
      render text: 'PDF did not render in time. Please refresh the page.'
    end
  end

  # PATCH /randomizations/1/undo
  def undo
    @randomization.undo!
    redirect_to project_randomizations_path(@project), notice: 'Randomization was successfully removed.'
  end

  # # DELETE /randomizations/1
  # def destroy
  #   @randomization.destroy
  #   redirect_to project_randomizations_path(@project), notice: 'Randomization was successfully deleted.'
  # end

  private

  def set_viewable_randomization
    @randomization = current_user.all_viewable_randomizations.find_by_id(params[:id])
    redirect_without_randomization
  end

  def set_editable_randomization
    @randomization = current_user.all_randomizations.find_by_id(params[:id])
    redirect_without_randomization
  end

  def redirect_without_randomization
    empty_response_or_root_path(project_randomizations_path(@project)) unless @randomization
  end
end
