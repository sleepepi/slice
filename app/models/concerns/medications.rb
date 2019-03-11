# frozen_string_literal: true

module Medications
  extend ActiveSupport::Concern

  included do
    # Relationships
    has_many :medication_variables, -> { current.order("position nulls last") }
    has_many :medications, -> { current }
    has_many :medication_values
  end
end
