# frozen_string_literal: true

# Describes a file that is uploaded as supporting documentation to a project.
class Document < ApplicationRecord
  mount_uploader :file, GenericUploader

  # Concerns
  include Searchable, Deletable

  # Model Validation
  validates :name, :category, :file, :project_id, :user_id, presence: true

  # Model Relationships
  belongs_to :user
  belongs_to :project

  # Model Methods

  def self.searchable_attributes
    %w(name category)
  end
end
