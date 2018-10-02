# frozen_string_literal: true

# Tracks analytics for Slice Expression Engine runs.
class EngineRun < ApplicationRecord
  # Constants
  ORDERS = {
    "runtime desc" => "engine_runs.runtime_ms desc",
    "runtime" => "engine_runs.runtime_ms",
    "subjects desc" => "engine_runs.subjects_count desc",
    "subjects" => "engine_runs.subjects_count",
    "sheets desc" => "engine_runs.sheets_count desc",
    "sheets" => "engine_runs.sheets_count",
    "run desc" => "engine_runs.id desc",
    "run" => "engine_runs.id"
  }
  DEFAULT_ORDER = "engine_runs.id desc"

  # Concerns
  include Searchable

  # Relationships
  belongs_to :project
  belongs_to :user

  # Methods
  def name
    "Run ##{id}"
  end

  def self.searchable_attributes
    %w(expression)
  end
end
