# frozen_string_literal: true

# Formats database responses for sheet variables and grids
module Formattable
  extend ActiveSupport::Concern

  def get_response(raw_format = :raw)
    case variable.variable_type
    when 'file'
      get_single_response(response_file, raw_format)
    when 'checkbox'
      get_multiple_responses(raw_format)
    when 'grid'
      get_grid_responses(raw_format)
    when 'signature'
      get_signature_response(raw_format)
    else
      get_single_response(response, raw_format)
    end
  end

  private

  def get_multiple_responses(raw_format)
    formatter = Formatters.for(variable)
    # Collect is used here since responses may be "built" and not yet saved to database
    values = responses.collect(&:value)
    raw_data = (raw_format == :raw)
    formatter.format_array(values, raw_data)
  end

  def get_single_response(r, raw_format)
    formatter = Formatters.for(variable)
    if raw_format == :raw
      formatter.raw_response(r)
    else
      formatter.name_response(r)
    end
  end

  def get_grid_responses(raw_format)
    return get_single_response(response, raw_format) unless respond_to?('grids')
    build_grid_responses(raw_format)
  end

  def build_grid_responses(raw_format)
    grid_responses = []
    all_grids = grids.to_a
    (0..all_grids.collect(&:position).max.to_i).each do |position|
      grid_responses[position] ||= {}
      variable.child_grid_variables.each do |child_grid_variable|
        grid = all_grids.find { |g| g.variable_id == child_grid_variable.child_variable_id && g.position == position }
        grid_responses[position][grid.variable.name] = grid.get_response(raw_format) if grid
      end
    end
    grid_responses.to_json
  end

  def get_signature_response(raw_format)
    if raw_format == :raw_file
      save_signature_file(raw_format)
    else
      get_single_response(response, raw_format)
    end
  end

  def save_signature_file(raw_format)
    file = Tempfile.new('signature.png')
    begin
      create_signature_png(response, file.path)
      file.define_singleton_method(:original_filename) do
        'signature.png'
      end
      self.response_file = file
      save
    ensure
      file.close
      file.unlink # deletes the temp file
    end
    response_file
  end

  def create_signature_png(signature, filename)
    canvas = ChunkyPNG::Canvas.new(300, 55)
    signature_array(signature).each do |hash|
      canvas.line(hash['mx'], hash['my'], hash['lx'], hash['ly'], ChunkyPNG::Color.parse('#145394'))
    end
    png = canvas.to_image
    png.save(filename)
  end

  def signature_array(signature)
    JSON.parse(signature)
  rescue
    []
  end
end
