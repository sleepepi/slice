class SubjectEvent < ActiveRecord::Base

  # Model Validation
  validates_presence_of :event_date

  # Model Relationships
  belongs_to :subject
  belongs_to :event

  # Model Methods

end
