class DesignOption < ActiveRecord::Base

  # Model Validation
  validates_presence_of :design_id

  validates_uniqueness_of :variable_id, allow_nil: true, scope: [:design_id]
  validates_uniqueness_of :section_id, allow_nil: true, scope: [:design_id]

  # Model Relationships
  belongs_to :design
  belongs_to :variable
  belongs_to :section

end
