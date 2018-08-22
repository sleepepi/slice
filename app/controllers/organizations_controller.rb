# frozen_string_literal: true

# Allows admins to create organizations.
class OrganizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin!
  before_action :find_organization_or_redirect, only: [
    :show, :edit, :update, :destroy
  ]

  # GET /organizations
  # GET /organizations.json
  def index
    scope = Organization.all.search(params[:search])
    @organizations = scope_order(scope).page(params[:page]).per(40)
  end

  # # GET /organizations/1
  # # GET /organizations/1.json
  # def show
  # end

  # GET /organizations/new
  def new
    @organization = Organization.new
  end

  # # GET /organizations/1/edit
  # def edit
  # end

  # POST /organizations
  # POST /organizations.json
  def create
    @organization = Organization.new(organization_params)

    respond_to do |format|
      if @organization.save
        format.html { redirect_to @organization, notice: "Organization was successfully created." }
        format.json { render :show, status: :created, location: @organization }
      else
        format.html { render :new }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /organizations/1
  # PATCH/PUT /organizations/1.json
  def update
    respond_to do |format|
      if @organization.update(organization_params)
        format.html { redirect_to @organization, notice: "Organization was successfully updated." }
        format.json { render :show, status: :ok, location: @organization }
      else
        format.html { render :edit }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organizations/1
  # DELETE /organizations/1.json
  def destroy
    @organization.destroy
    respond_to do |format|
      format.html { redirect_to organizations_path, notice: "Organization was successfully deleted." }
      format.json { head :no_content }
    end
  end

  private

  def find_organization_or_redirect
    @organization = Organization.find_by(id: params[:id])
    empty_response_or_root_path organizations_path unless @organization
  end

  def organization_params
    params.require(:organization).permit(:name, :profile_picture)
  end

  def scope_order(scope)
    @order = scrub_order(Organization, params[:order], "organizations.name")
    scope.reorder(@order)
  end
end
