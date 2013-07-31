class SurveyController < ApplicationController

  def index
    render layout: 'minimal_layout'
  end

  def show
    @design = Design.current.where( publicly_available: true ).find_by_slug(params[:slug])
    if @design and @project = @design.project
      render 'designs/survey', layout: 'minimal_layout'
    else
      redirect_to about_path
    end
  end

end
