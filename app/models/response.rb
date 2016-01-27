# frozen_string_literal: true

class Response < ActiveRecord::Base
  # Model Validation
  validates :variable_id, :value, presence: true

  # Model Relationships
  belongs_to :variable
  belongs_to :sheet
  belongs_to :sheet_variable
  belongs_to :grid
  belongs_to :user
end
