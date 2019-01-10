class AeTeamMember < ApplicationRecord
  # Concerns

  # Validations

  # Relationships
  belongs_to :project
  belongs_to :ae_team
  belongs_to :user
end
