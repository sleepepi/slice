# frozen_string_literal: true

module Valuable
  extend ActiveSupport::Concern

  include DateAndTimeParser

  included do
    # Scopes
    def self.pluck_domain_option_value_or_value
      left_outer_joins(:domain_option)
        .pluck("domain_options.value", :value)
        .collect { |v1, v2| v1 || v2 }
    end

    # Validations
    validates :variable_id, presence: true

    # Relationships
    belongs_to :variable
    has_many :responses

    mount_uploader :response_file, GenericUploader
  end

  # Methods

  # TODO: Move method to "Slicers"
  def update_responses!(values, current_user, sheet)
    class_foreign_key = "#{self.class.name.underscore}_id".to_sym

    # Could use pluck, but pluck has issues with scopes and unsaved objects
    old_response_ids = responses.collect(&:id)

    domain_options = variable.domain_options.to_a

    self.responses = values.select(&:present?).collect do |value|
      domain_option = domain_options.find { |option| option.value == value.to_s }
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
  # TODO: Deprecate this in favor of using "Slicers"
  def format_response(response)
    response = response.to_unsafe_hash if response.is_a?(ActionController::Parameters)
    slicer = Slicers.for(variable)
    update_hash = slicer.format_for_db_update(response)
    if variable.variable_type == "file" && response.present?
      response
    elsif variable.variable_type == "file" && response.blank?
      {}
    else
      update_hash
    end
  end
end
