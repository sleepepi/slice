class SurveyController < ApplicationController

  before_action :set_public_design,         only: [ :show, :section_image ]
  before_action :redirect_without_design,   only: [ :show, :section_image ]
  before_action :set_section,               only: [ :section_image ]
  before_action :redirect_without_section,  only: [ :section_image ]


  def index
    render layout: 'minimal_layout'
  end

  def show
    render 'designs/survey', layout: 'minimal_layout'
  end

  def section_image
    send_file File.join( CarrierWave::Uploader::Base.root, @section.image.url )
  end

  private

    def set_public_design
      @design = Design.current.where( publicly_available: true ).find_by_slug(params[:slug])
      @project = @design.project if @design
    end

    def redirect_without_design
      empty_response_or_root_path(about_survey_path) unless @design
    end

    def set_section
      @section = @design.sections.find_by_id(params[:section_id])
    end

    def redirect_without_section
      empty_response_or_root_path(about_survey_path) unless @section
    end

end
