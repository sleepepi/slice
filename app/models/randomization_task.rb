# frozen_string_literal: true

# Links a set of tasks to a randomization.
class RandomizationTask < ApplicationRecord
  # Model Relationships
  belongs_to :randomization
  belongs_to :task, dependent: :destroy
end
