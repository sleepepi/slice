# frozen_string_literal: true

# Allows project editors to create a list of contacts for the project
class ContactsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_editable_project, only: [:index, :show, :new, :edit, :create, :update, :destroy]
  before_action :redirect_without_project, only: [:index, :show, :new, :edit, :create, :update, :destroy]
  before_action :set_editable_contact, only: [:show, :edit, :update, :destroy]

  # GET /contacts
  def index
    @order = scrub_order(Contact, params[:order], 'contacts.name')
    @contacts = @project.contacts
                        .search(params[:search]).order(@order)
                        .page(params[:page]).per(20)
  end

  # GET /contacts/1
  def show
  end

  # GET /contacts/new
  def new
    @contact = current_user.contacts.where(project_id: @project.id).new
  end

  # GET /contacts/1/edit
  def edit
  end

  # POST /contacts
  def create
    @contact = current_user.contacts.where(project_id: @project.id).new(contact_params)

    if @contact.save
      redirect_to [@contact.project, @contact], notice: 'Contact was successfully created.'
    else
      render action: :new
    end
  end

  # PATCH /contacts/1
  def update
    if @contact.update(contact_params)
      redirect_to [@contact.project, @contact], notice: 'Contact was successfully updated.'
    else
      render action: :edit
    end
  end

  # DELETE /contacts/1
  def destroy
    @contact.destroy
    redirect_to project_contacts_path(@project)
  end

  private

  def set_editable_contact
    @contact = @project.contacts.find_by_id params[:id]
    redirect_without_contact
  end

  def redirect_without_contact
    empty_response_or_root_path(project_contacts_path(@project)) unless @contact
  end

  def contact_params
    params[:contact] ||= { blank: '1' }
    check_key_and_set_default_value(:contact, :position, 0)
    params.require(:contact).permit(
      :title, :name, :phone, :fax, :email, :position, :archived
    )
  end
end
