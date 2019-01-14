# frozen_string_literal: true

# Attaches objects to log entries.
class AeLogEntryAttachment < ApplicationRecord
  # Relationships
  belongs_to :ae_log_entry
  belongs_to :attachment, polymorphic: true
end
