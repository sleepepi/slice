# frozen_string_literal: true

# Allows unblinded project and site members to view randomizations. Project
# editors are able to undo randomizations.
class RandomizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_project_or_redirect, only: [:index, :export, :show, :schedule]
  before_action :find_editable_project_or_editable_site_or_redirect, only: [:choose_scheme, :undo]
  before_action :redirect_blinded_users
  before_action :find_viewable_randomization_or_redirect, only: [:show, :schedule]
  before_action :find_editable_randomization_or_redirect, only: [:undo]

  layout "layouts/full_page_sidebar"

  # GET /randomizations/choose-scheme
  def choose_scheme
    return unless @project.randomization_schemes.published.count == 1
    redirect_to randomize_subject_to_list_project_randomization_scheme_path(
      @project,
      @project.randomization_schemes.published.first
    )
  end

  # GET /randomizations/export
  def export
    @export = current_user.exports
                          .where(project_id: @project.id, name: @project.name_with_date_for_file, total_steps: 1)
                          .create(include_randomizations: true)
    @export.generate_export_in_background!
    redirect_to [@project, @export]
  end

  # GET /randomizations
  def index
    scope = current_user.all_viewable_randomizations.where(project_id: @project.id).includes(:subject)
    scope = scope_includes(scope)
    scope = scope_filter(scope)
    @randomizations = scope_order(scope).page(params[:page]).per(40)
  end

  # # GET /randomizations/1
  # def show
  # end

  # GET /randomizations/1/schedule.pdf
  def schedule
    randomization_schedule_print = @randomization.randomization_schedule_prints.where(language: World.language).first_or_create
    randomization_schedule_print.regenerate! if randomization_schedule_print.regenerate?
    send_file_if_present randomization_schedule_print.file, type: "application/pdf", disposition: "inline"
  end

  # PATCH /randomizations/1/undo
  def undo
    @randomization.undo!
    redirect_to project_randomizations_path(@project), notice: "Randomization was successfully removed."
  end

  private

  def find_viewable_randomization_or_redirect
    @randomization = current_user.all_viewable_randomizations.find_by(id: params[:id])
    redirect_without_randomization
  end

  def find_editable_randomization_or_redirect
    @randomization = current_user.all_randomizations.find_by(id: params[:id])
    redirect_without_randomization
  end

  def redirect_without_randomization
    empty_response_or_root_path(project_randomizations_path(@project)) unless @randomization
  end

  def scope_includes(scope)
    scope.includes(
      :list, :randomized_by, :randomization_scheme, { subject: :site },
      :treatment_arm
    )
  end

  def scope_filter(scope)
    scope = scope.with_site(params[:site_id]) if params[:site_id].present?
    [:treatment_arm_id, :randomized_by_id, :scheme_id].each do |key|
      scope = scope.where(key => params[key]) if params[key].present?
    end
    scope
  end

  def scope_order(scope)
    @order = params[:order]
    scope.order(Arel.sql(Randomization::ORDERS[params[:order]] || Randomization::DEFAULT_ORDER))
  end
end
