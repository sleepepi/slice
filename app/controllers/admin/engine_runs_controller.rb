# frozen_string_literal: true

# Allows admins to view past Slice Expression Engine run analytics.
class Admin::EngineRunsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin!
  before_action :find_engine_run_or_redirect, only: [:show, :destroy]

  layout "layouts/full_page_sidebar"

  # GET /admin/engine-runs
  def index
    scope = EngineRun.all.includes(:user, :project).search_any_order(params[:search])
    @engine_runs = scope_order(scope).page(params[:page]).per(20)
  end

  # # GET /admin/engine-runs/1
  # def show
  # end

  # DELETE /admin/engine-runs/1
  def destroy
    @engine_run.destroy
    redirect_to admin_engine_runs_path, notice: "Engine run was successfully deleted."
  end

  private

  def find_engine_run_or_redirect
    @engine_run = EngineRun.find_by(id: params[:id])
    empty_response_or_root_path(admin_engine_runs_path) unless @engine_run
  end

  def scope_order(scope)
    @order = params[:order]
    scope.order(Arel.sql(EngineRun::ORDERS[params[:order]] || EngineRun::DEFAULT_ORDER))
  end
end
