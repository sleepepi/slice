class ContactsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_editable_project, only: [ :index, :show, :new, :edit, :create, :update, :destroy ]
  before_filter :redirect_without_project, only: [ :index, :show, :new, :edit, :create, :update, :destroy ]
  before_filter :set_editable_contact, only: [ :show, :edit, :update, :destroy ]
  before_filter :redirect_without_contact, only: [ :show, :edit, :update, :destroy ]


  # GET /contacts
  # GET /contacts.json
  def index
    @order = scrub_order(Contact, params[:order], "contacts.name")
    @contacts = @project.contacts.search(params[:search]).order(@order).page(params[:page]).per( 20 )

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @contacts }
    end
  end

  # GET /contacts/1
  # GET /contacts/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @contact }
    end
  end

  # GET /contacts/new
  # GET /contacts/new.json
  def new
    @contact = @project.contacts.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @contact }
    end
  end

  # GET /contacts/1/edit
  def edit
    respond_to do |format|
      format.html # edit.html.erb
      format.json { render json: @contact }
    end
  end

  # POST /contacts
  # POST /contacts.json
  def create
    @contact = @project.contacts.new(post_params)

    respond_to do |format|
      if @contact.save
        format.html { redirect_to [@contact.project, @contact], notice: 'Contact was successfully created.' }
        format.json { render json: @contact, status: :created, location: @contact }
      else
        format.html { render action: "new" }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /contacts/1
  # PUT /contacts/1.json
  def update
    respond_to do |format|
      if @contact.update_attributes(post_params)
        format.html { redirect_to [@contact.project, @contact], notice: 'Contact was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    @contact.destroy

    respond_to do |format|
      format.html { redirect_to project_contacts_path }
      format.json { head :no_content }
    end
  end

  private

  def post_params
    params[:contact] ||= {}

    params[:contact][:user_id] = current_user.id
    params[:contact][:position] = 0 if params[:contact][:position].blank?

    params[:contact].slice(
      :title, :name, :phone, :fax, :email, :position, :user_id, :archived
    )
  end

  def set_editable_contact
    @contact = @project.contacts.find_by_id(params[:id])
  end

  def redirect_without_contact
    empty_response_or_root_path(project_contacts_path) unless @contact
  end

end
