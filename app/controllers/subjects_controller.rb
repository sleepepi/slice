class SubjectsController < ApplicationController
  before_filter :authenticate_user!

  # GET /subjects
  # GET /subjects.json
  def index
    subject_scope = Subject.current
    @order = Subject.column_names.collect{|column_name| "subjects.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "subjects.subject_code"
    subject_scope = subject_scope.order(@order)
    @subjects = subject_scope.page(params[:page]).per( 20 )

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @subjects }
    end
  end

  # GET /subjects/1
  # GET /subjects/1.json
  def show
    @subject = Subject.current.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @subject }
    end
  end

  # GET /subjects/new
  # GET /subjects/new.json
  def new
    @subject = Subject.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @subject }
    end
  end

  # GET /subjects/1/edit
  def edit
    @subject = Subject.current.find(params[:id])
  end

  # POST /subjects
  # POST /subjects.json
  def create
    @subject = current_user.subjects.new(post_params)

    respond_to do |format|
      if @subject.save
        format.html { redirect_to @subject, notice: 'Subject was successfully created.' }
        format.json { render json: @subject, status: :created, location: @subject }
      else
        format.html { render action: "new" }
        format.json { render json: @subject.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /subjects/1
  # PUT /subjects/1.json
  def update
    @subject = Subject.current.find(params[:id])

    respond_to do |format|
      if @subject.update_attributes(post_params)
        format.html { redirect_to @subject, notice: 'Subject was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @subject.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subjects/1
  # DELETE /subjects/1.json
  def destroy
    @subject = Subject.current.find(params[:id])
    @subject.destroy

    respond_to do |format|
      format.html { redirect_to subjects_url }
      format.json { head :no_content }
    end
  end

  private

  def post_params

    [].each do |date|
      params[:subject][date] = parse_date(params[:subject][date])
    end

    params[:subject] ||= {}
    params[:subject].slice(
      :project_id, :subject_code
    )
  end
end
