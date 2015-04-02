class SubjectEvent < ActiveRecord::Base

  # Model Validation


  # Model Relationships
  belongs_to :subject
  belongs_to :event

  # Model Methods

end
