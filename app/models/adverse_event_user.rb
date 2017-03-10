# frozen_string_literal: true

# Keeps track of when the user last viewed an adverse event to provide better
# notifications to user of updates to the AE.
class AdverseEventUser < ApplicationRecord
  # Validations
  validates :adverse_event_id, :user_id, :last_viewed_at, presence: true

  # Relationships
  belongs_to :adverse_event
  belongs_to :user

  # Methods
  def created_at
    last_viewed_at
  end
end
