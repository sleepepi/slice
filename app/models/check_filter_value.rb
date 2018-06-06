# frozen_string_literal: true

# Allows project editors to specify values for filters.
class CheckFilterValue < ApplicationRecord
  # Validations
  validates :project_id, :user_id, :check_id, :check_filter_id, :value,
            presence: true
  validates :value, format: { with: /\A(\-)?[a-z0-9]*\Z/i }

  # Relationships
  belongs_to :project
  belongs_to :user
  belongs_to :check
  belongs_to :check_filter

  # Methods
end
