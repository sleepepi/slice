# frozen_string_literal: true

# Defines variables that are listed on a grid as well as their position.
class GridVariable < ApplicationRecord
  # Model Validation
  validates :project_id, :parent_variable_id, :child_variable_id, presence: true
  validates :child_variable_id, uniqueness: { scope: :parent_variable_id }

  # Model Relationships
  belongs_to :project
  belongs_to :parent_variable, class_name: 'Variable'
  belongs_to :child_variable, class_name: 'Variable'
end
