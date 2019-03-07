# frozen_string_literal: true

module Medications
  extend ActiveSupport::Concern

  included do
    # Relationships
    has_many :medication_variables, -> { current }
    has_many :medications
  end
end
