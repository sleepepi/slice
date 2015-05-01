class SubjectEvent < ActiveRecord::Base

  # Model Validation

  # Model Relationships
  belongs_to :subject
  belongs_to :event

  # Model Methods

  def event_date_to_param
    self.event_date ? self.event_date.strftime("%Y%m%d") : 'no-date'
  end

  def event_date_to_s
    self.event_date ? self.event_date.strftime("%a, %B %d, %Y") : 'No Date'
  end

end
