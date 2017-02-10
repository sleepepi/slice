# frozen_string_literal: true

module Valuable
  extend ActiveSupport::Concern

  include DateAndTimeParser

  included do
    # Scopes
    def self.pluck_domain_option_value_or_response
      left_outer_joins(:domain_option)
        .pluck('domain_options.value', :response)
        .collect { |value, response| value || response }
    end

    # Model Validation
    validates :variable_id, presence: true

    # Model Relationships
    belongs_to :variable
    has_many :responses

    mount_uploader :response_file, GenericUploader
  end

  # Methods

  def update_responses!(values, current_user, sheet)
    class_foreign_key = "#{self.class.name.underscore}_id".to_sym

    # Could use pluck, but pluck has issues with scopes and unsaved objects
    old_response_ids = responses.collect(&:id)

    self.responses = values.select(&:present?).collect do |value|
      domain_option = variable.domain_options.find_by(value: value)
      if domain_option
        new_domain_option_id = domain_option.id
        new_value = nil
      else
        new_domain_option_id = nil
        new_value = value
      end

      Response.where(class_foreign_key => id,
                     sheet_id: sheet.id,
                     variable_id: variable_id,
                     value: new_value,
                     domain_option_id: new_domain_option_id)
              .first_or_create(user_id: (current_user ? current_user.id : nil))
    end
    Response.where(id: old_response_ids, class_foreign_key => nil).destroy_all
  end

  # Returns response as a hash that can sent to update method
  def format_response(response)
    if response.is_a?(ActionController::Parameters)
      response = response.to_unsafe_hash
    end

    case variable.variable_type
    when 'file'
      response = {} if response.blank?
    when 'date'
      month = parse_integer(response[:month])
      day = parse_integer(response[:day])
      year = parse_integer(response[:year])

      # Save valuable to string in "%Y-%m-%d" db format, passing in a date
      response = { response: parse_date("#{month}/#{day}/#{year}") }
    when 'time_of_day'
      # Save valuable to string in total seconds since midnight db format
      response = { response: parse_time_of_day_from_hash_to_s(response) }
    when 'time_duration'
      # Save valuable to string in total seconds db format
      response = { response: parse_time_duration_from_hash_to_s(response, no_hours: variable.no_hours?) }
    when 'imperial_height'
      # Save valuable to string in total inches db format
      response = { response: parse_imperial_height_from_hash_to_s(response) }
    when 'imperial_weight'
      # Save valuable to string in total ounces db format
      response = { response: parse_imperial_weight_from_hash_to_s(response) }
    else
      domain_option = variable.domain_options.find_by(value: response)
      response = \
        if domain_option
          { response: nil, domain_option_id: domain_option.id }
        else
          { response: response, domain_option_id: nil }
        end
    end
    response
  end
end
