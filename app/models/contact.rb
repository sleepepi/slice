# frozen_string_literal: true

class Contact < ApplicationRecord
  # Concerns
  include Searchable, Deletable

  # Model Validation
  validates :title, :name, :project_id, :user_id, presence: true

  # Model Relationships
  belongs_to :user
  belongs_to :project

  # Model Methods

  def self.searchable_attributes
    %w(name title)
  end
end
