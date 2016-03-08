# frozen_string_literal: true

# Grants access to public surveys for images, adding grid rows, variable
# typeahead, and formatting variable numbers.
class ExternalController < ApplicationController
  prepend_before_action { request.env['devise.skip_timeout'] = true }
  skip_before_action :verify_authenticity_token

  before_action :set_design, only: [:add_grid_row, :format_number, :section_image, :typeahead]
  before_action :set_section, only: [:section_image]
  before_action :set_variable, only: [:add_grid_row, :format_number, :typeahead]

  # POST /external/add_grid_row.js?design=REQUIRED&variable_id=REQUIRED
  #      &design_option_id=REQUIRED&header=OPTIONAL&handoff=OPTIONAL
  def add_grid_row
    @design_option = @design.design_options.find_by_id params[:design_option_id] if @design
  end

  # GET /external/format_number.json
  def format_number
    @result = format_calculated_number_params
  end

  # GET /external/typeahead.js
  def typeahead
    array = if ['string'].include?(@variable.variable_type)
              @variable.autocomplete_array.select do |i|
                i.to_s.downcase.include?(params[:query].to_s.downcase)
              end
            else
              []
            end
    render json: array
  end

  # Image returned or blank
  # GET /external/image/:section_id?design=REQUIRED&handoff=OPTIONAL
  def section_image
    if @section
      send_file File.join(CarrierWave::Uploader::Base.root, @section.image.url)
    else
      head :ok
    end
  end

  private

  def set_design
    @design = set_publicly_viewabled_design
    @design = set_handoff_design unless @design
    @design = set_current_user_design unless @design
  end

  def set_publicly_viewabled_design
    Design.current.where(publicly_available: true).find_by_param params[:design]
  end

  def set_handoff_design
    handoff = Handoff.find_by_param params[:handoff]
    handoff.subject_event.event.designs.find_by_param(params[:design]) if handoff
  end

  def set_current_user_design
    current_user.all_viewable_designs.find_by_param params[:design] if current_user
  end

  def set_section
    @section = @design.sections.find_by_id(params[:section_id]) if @design
  end

  def set_variable
    if @design
      variable = @design.project.variables.find_by_id(params[:variable_id])
      if variable && variable.inherited_designs.collect(&:id).include?(@design.id)
        @variable = variable
      end
    end
    empty_response_or_root_path unless @variable
  end

  def format_calculated_number_params
    if @variable.format.blank?
      params[:calculated_number]
    else
      @variable.format % params[:calculated_number]
    end
  rescue
    params[:calculated_number]
  end
end
