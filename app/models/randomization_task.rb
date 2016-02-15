class RandomizationTask < ActiveRecord::Base
  # Model Relationships
  belongs_to :randomization
  belongs_to :task, dependent: :destroy
end
