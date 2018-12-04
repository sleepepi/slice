# frozen_string_literal: true

# For lack of a better name, this association assigns a design to the list of
# designs that can be completed by a reporter of an adverse event, or the list
# of designs a reviewer has to fill out on a given AE team pathway.
class AeDesignment < ApplicationRecord
  # Relationships
  belongs_to :project
  belongs_to :design
  belongs_to :ae_review_team, optional: true
  belongs_to :ae_team_pathway, optional: true
end
