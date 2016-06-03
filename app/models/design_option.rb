# frozen_string_literal: true

# Defines the position of sections and questions on designs. Design options also
# have associated branching logic, and can be set as recommended or required
class DesignOption < ActiveRecord::Base
  REQUIRED = [['Not Required', ''], ['Recommended', 'recommended'], ['Required', 'required']]

  # Model Validation
  validates :design_id, presence: true
  validates :variable_id, uniqueness: { scope: [:design_id] }, allow_nil: true
  validates :section_id, uniqueness: { scope: [:design_id] }, allow_nil: true

  # Model Relationships
  belongs_to :design
  belongs_to :variable
  belongs_to :section, dependent: :destroy
end
