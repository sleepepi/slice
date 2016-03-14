class RandomizationTask < ApplicationRecord
  # Model Relationships
  belongs_to :randomization
  belongs_to :task, dependent: :destroy
end
