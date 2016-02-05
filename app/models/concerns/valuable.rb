# frozen_string_literal: true

require 'valuables'

module Valuable
  extend ActiveSupport::Concern

  include Valuables, DateAndTimeParser

  included do
    # Named Scopes
    scope :with_variable_type, lambda { |arg| where( "#{self.table_name}.variable_id in (SELECT variables.id from variables where variables.variable_type IN (?))", arg ) }

    # Model Validation
    validates_presence_of :variable_id

    # Model Relationships
    belongs_to :variable
    has_many :responses

    mount_uploader :response_file, GenericUploader
  end

  def update_responses!(values, current_user, sheet)
    class_foreign_key = "#{self.class.name.underscore}_id".to_sym

    # Could use pluck, but pluck has issues with scopes and unsaved objects
    old_response_ids = self.responses.collect { |r| r.id }

    new_responses = []
    values.select{|v| not v.blank?}.each do |value|
      new_responses << Response.where(class_foreign_key => self.id, sheet_id: sheet.id, variable_id: self.variable_id, value: value).first_or_create( user_id: (current_user ? current_user.id : nil) )
    end
    self.responses = new_responses
    Response.where(id: old_response_ids, class_foreign_key => nil).destroy_all
  end

  def get_response(raw_format = :raw)
    Valuables.for(self).send(raw_format)
  end

  # Returns response as a hash that can sent to update_attributes
  def format_response(variable_type, response)
    case variable_type when 'file'
      response = {} if response.blank?
    when 'date'
      month = parse_integer(response[:month])
      day = parse_integer(response[:day])
      year = parse_integer(response[:year])

      # Save valuable to string in "%Y-%m-%d" db format, passing in a date
      response = { response: parse_date("#{month}/#{day}/#{year}") }
    when 'time'
      # Save valuable to string in "%H:%M:%S" db format
      response = { response: parse_time_from_hash_to_s(response) }
    when 'time_duration'
      # Save valuable to string in "%H:%M:%S" db format
      response = { response: parse_time_duration_from_hash_to_s(response) }
    else
      response = { response: response }
    end
    response
  end
end
