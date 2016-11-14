# frozen_string_literal: true

# Tracks if a sheet has passed or failed a check.
class StatusCheck < ApplicationRecord
  # Relationships
  belongs_to :check
  belongs_to :sheet
end
