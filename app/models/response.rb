# frozen_string_literal: true

# Tracks a response to a multichoice variable.
class Response < ApplicationRecord
  # Scopes
  # TODO: Move to valuable later...
  def self.pluck_domain_option_value_or_value
    left_outer_joins(:domain_option)
      .pluck('domain_options.value', :value)
      .collect { |v1, v2| v1 || v2 }
  end

  # Validations
  validates :variable_id, :sheet_id, presence: true

  # Relationships
  belongs_to :variable
  belongs_to :sheet
  belongs_to :sheet_variable
  belongs_to :grid
  belongs_to :user
  belongs_to :domain_option

  # Methods
  def domain_option_value_or_value
    if domain_option
      domain_option.value
    else
      value
    end
  end
end
