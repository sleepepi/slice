# frozen_string_literal: true

# Associates a user with an AE review team. Team members can be managers,
# principal reviewers, reviewers, and viewers.
class AeTeamMember < ApplicationRecord
  # Concerns

  # Validations

  # Relationships
  belongs_to :project
  belongs_to :ae_team
  belongs_to :user
end
