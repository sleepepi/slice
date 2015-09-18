class Grid < ActiveRecord::Base
  # Concerns
  include Valuable

  # Model Validation
  validates :sheet_variable_id, :position, presence: true

  # Model Relationships
  belongs_to :sheet_variable, touch: true
  belongs_to :user

  delegate :sheet_id, to: :sheet_variable
end
