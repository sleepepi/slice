# frozen_string_literal: true

# Defines a check that can be run on a project to identify data inconsistencies.
class Check < ApplicationRecord
  # Concerns
  include Deletable, Sluggable

  # Model Validation
  validates :project_id, :user_id, :name, presence: true
  validates :slug, uniqueness: { scope: :project_id },
                   format: { with: /\A[a-z][a-z0-9\-]*\Z/ },
                   allow_nil: true

  # Model Relationships
  belongs_to :project
  belongs_to :user

  # Methods
  def destroy
    update slug: nil
    super
  end
end
