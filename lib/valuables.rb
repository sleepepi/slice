# frozen_string_literal: true

require 'valuables/default'
require 'valuables/domain_response'
require 'valuables/date_response'
require 'valuables/file_attachment'
require 'valuables/grid_response'
require 'valuables/integer_response'
require 'valuables/numeric_response'
require 'valuables/multiple_response'
require 'valuables/single_response'
require 'valuables/time_response'
require 'valuables/time_duration_response'
require 'valuables/signature_response'

module Valuables
  DEFAULT_CLASS = Valuables::Default
  VALUABLE_CLASSES = {
    'calculated' => NumericResponse,
    'checkbox' => MultipleResponse,
    'date' => DateResponse,
    'dropdown' => SingleResponse,
    'file' => FileAttachment,
    'grid' => GridResponse,
    'integer' => IntegerResponse,
    'numeric' => NumericResponse,
    'radio' => SingleResponse,
    'string' => Default,
    'text' => Default,
    'time' => TimeResponse,
    'time_duration' => TimeDurationResponse,
    'signature' => SignatureResponse
  }

  def self.for(object)
    (VALUABLE_CLASSES[object.variable.variable_type] || DEFAULT_CLASS).new(object)
  end
end
