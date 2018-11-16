class AeLogEntryAttachment < ApplicationRecord

  # Relationships
  belongs_to :ae_adverse_event_log_entry
  belongs_to :attachment, polymorphic: true
end
