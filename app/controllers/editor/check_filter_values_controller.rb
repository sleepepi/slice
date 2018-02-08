# frozen_string_literal: true

# Allows project editors to add values to check filters.
class Editor::CheckFilterValuesController < Editor::EditorController
  before_action :find_check_or_redirect
  before_action :find_filter_or_redirect
  before_action :find_filter_value_or_redirect, only: [:show, :edit, :update, :destroy]

  layout "layouts/full_page_sidebar"

  # GET /editor/projects/1/checks/1/filters/1/values
  def index
    @check_filter_values = @check_filter.check_filter_values
                                        .page(params[:page]).per(40)
  end

  # # GET /editor/projects/1/checks/1/filters/1/values/1
  # def show
  # end

  # GET /editor/projects/1/checks/1/filters/1/values/new
  def new
    @check_filter_value = @check_filter.check_filter_values.new
  end

  # # GET /editor/projects/1/checks/1/filters/1/values/1/edit
  # def edit
  # end

  # POST /editor/projects/1/checks/1/filters/1/values
  def create
    @check_filter_value = current_user.check_filter_values
                                      .where(
                                        project_id: @project.id,
                                        check_id: @check.id,
                                        check_filter_id: @check_filter.id
                                      )
                                      .new(check_filter_value_params)
    if @check_filter_value.save
      redirect_to editor_project_check_check_filter_check_filter_value_path(
        @project, @check, @check_filter, @check_filter_value
      ), notice: "Check filter value was successfully created."
    else
      render :new
    end
  end

  # PATCH /editor/projects/1/checks/1/filters/1/values/1
  def update
    if @check_filter_value.update(check_filter_value_params)
      redirect_to editor_project_check_check_filter_check_filter_value_path(
        @project, @check, @check_filter, @check_filter_value
      ), notice: "Check filter value was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /editor/projects/1/checks/1/filters/1/values/1
  def destroy
    @check_filter_value.destroy
    redirect_to editor_project_check_check_filter_check_filter_values_path(
      @project, @check, @check_filter
    ), notice: "Check filter value was successfully deleted."
  end

  private

  def find_filter_value_or_redirect
    super(:id)
  end

  def check_filter_value_params
    params.require(:check_filter_value).permit(:value)
  end
end
