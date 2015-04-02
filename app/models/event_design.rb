class EventDesign < ActiveRecord::Base

  # Model Validation
  validates_uniqueness_of :position, scope: [ :event_id, :design_id ]

  # Model Relationships
  belongs_to :event
  belongs_to :design

  # Model Methods

end
