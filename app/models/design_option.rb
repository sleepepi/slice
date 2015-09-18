class DesignOption < ActiveRecord::Base
  # Model Validation
  validates :design_id, presence: true
  validates :variable_id, uniqueness: { scope: [:design_id] }, allow_nil: true
  validates :section_id, uniqueness: { scope: [:design_id] }, allow_nil: true

  # Model Relationships
  belongs_to :design
  belongs_to :variable
  belongs_to :section, dependent: :destroy
end
