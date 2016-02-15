# frozen_string_literal: true

# Creates a template for a task for a randomization scheme
class RandomizationSchemeTask < ActiveRecord::Base
  # Model Relationships
  belongs_to :randomization_scheme
end
