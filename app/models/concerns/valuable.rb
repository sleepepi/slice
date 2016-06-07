# frozen_string_literal: true

module Valuable
  extend ActiveSupport::Concern

  include DateAndTimeParser

  included do
    # Named Scopes
    scope :with_variable_type, lambda { |arg| where("#{table_name}.variable_id in (SELECT variables.id from variables where variables.variable_type IN (?))", arg) }

    # Model Validation
    validates :variable_id, presence: true

    # Model Relationships
    belongs_to :variable
    has_many :responses

    mount_uploader :response_file, GenericUploader
  end

  def update_responses!(values, current_user, sheet)
    class_foreign_key = "#{self.class.name.underscore}_id".to_sym

    # Could use pluck, but pluck has issues with scopes and unsaved objects
    old_response_ids = responses.collect(&:id)

    self.responses = values.select(&:present?).collect do |value|
      Response.where(class_foreign_key => id,
                     sheet_id: sheet.id,
                     variable_id: variable_id,
                     value: value)
              .first_or_create(user_id: (current_user ? current_user.id : nil))
    end
    Response.where(id: old_response_ids, class_foreign_key => nil).destroy_all
  end

  # Returns response as a hash that can sent to update_attributes
  def format_response(variable_type, response)
    if response.is_a? ActionController::Parameters
      response = response.to_unsafe_hash
    end

    case variable_type
    when 'file'
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
    when 'imperial_height'
      # Save valuable to string in inches db format
      response = { response: parse_imperial_height_from_hash_to_s(response) }
    when 'imperial_weight'
      # Save valuable to string in ounces db format
      response = { response: parse_imperial_weight_from_hash_to_s(response) }
    else
      response = { response: response }
    end
    response
  end
end
