class ContactsController < ApplicationController
  before_filter :authenticate_user!

  # GET /contacts
  # GET /contacts.json
  def index
    @project = current_user.all_projects.find_by_id(params[:project_id])

    if @project
      contact_scope = @project.contacts.scoped()
      @order = scrub_order(Contact, params[:order], "contacts.name")
      contact_scope = contact_scope.order(@order)
      @contact_count = contact_scope.count
      @contacts = contact_scope.page(params[:page]).per( 20 )
    end

    respond_to do |format|
      if @project
        format.html # index.html.erb
        format.js
        format.json { render json: @contacts }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # GET /contacts/1
  # GET /contacts/1.json
  def show
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @contact = @project.contacts.find_by_id(params[:id]) if @project

    respond_to do |format|
      if @project
        format.html # show.html.erb
        format.json { render json: @contact }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # GET /contacts/new
  # GET /contacts/new.json
  def new
    @contact = Contact.new(project_id: params[:project_id])

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @contact }
    end
  end

  # GET /contacts/1/edit
  def edit
    @contact = Contact.current.find(params[:id])
  end

  # POST /contacts
  # POST /contacts.json
  def create
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @contact = @project.contacts.new(post_params) if @project

    respond_to do |format|
      if @project
        if @contact.save
          format.html { redirect_to [@contact.project, @contact], notice: 'Contact was successfully created.' }
          format.json { render json: @contact, status: :created, location: @contact }
        else
          format.html { render action: "new" }
          format.json { render json: @contact.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # PUT /contacts/1
  # PUT /contacts/1.json
  def update
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @contact = @project.contacts.find_by_id(params[:id]) if @project

    respond_to do |format|
      if @project
        if @contact.update_attributes(post_params)
          format.html { redirect_to [@contact.project, @contact], notice: 'Contact was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @contact.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @contact = @project.contacts.find_by_id(params[:id]) if @project

    respond_to do |format|
      if @project
        @contact.destroy
        format.html { redirect_to project_contacts_path }
        format.json { head :no_content }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  private

  def post_params
    params[:contact] ||= {}

    params[:contact][:user_id] = current_user.id
    params[:contact][:position] = 0 if params[:contact][:position].blank?

    params[:contact].slice(
      :title, :name, :phone, :fax, :email, :position, :user_id
    )
  end
end
