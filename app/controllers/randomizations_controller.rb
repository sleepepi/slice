# frozen_string_literal: true

# Allows unblinded project and site members to view randomizations. Project
# editors are able to undo randomizations.
class RandomizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_project_or_redirect, only: [:index, :show, :schedule]
  before_action :find_editable_project_or_editable_site_or_redirect, only: [:choose_scheme, :undo]
  before_action :redirect_blinded_users
  before_action :find_viewable_randomization_or_redirect, only: [:show, :schedule]
  before_action :find_editable_randomization_or_redirect, only: [:undo]

  def choose_scheme
    if @project.randomization_schemes.published.count == 1
      redirect_to randomize_subject_to_list_project_randomization_scheme_path(
        @project,
        @project.randomization_schemes.published.first
      )
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
    if File.exist? file_pdf_location
      send_file file_pdf_location, filename: 'schedule.pdf', type: 'application/pdf', disposition: 'inline'
    else
      redirect_to [@project, @randomization], alert: 'Unable to generate PDF.'
    end
  end

  # PATCH /randomizations/1/undo
  def undo
    @randomization.undo!
    redirect_to project_randomizations_path(@project), notice: 'Randomization was successfully removed.'
  end

  private

  def find_viewable_randomization_or_redirect
    @randomization = current_user.all_viewable_randomizations.find_by_id(params[:id])
    redirect_without_randomization
  end

  def find_editable_randomization_or_redirect
    @randomization = current_user.all_randomizations.find_by_id(params[:id])
    redirect_without_randomization
  end

  def redirect_without_randomization
    empty_response_or_root_path(project_randomizations_path(@project)) unless @randomization
  end
end
