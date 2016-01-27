# frozen_string_literal: true

class Link < ActiveRecord::Base
  # Concerns
  include Searchable, Deletable

  # Model Validation
  validates :name, :category, :url, :project_id, :user_id, presence: true

  # Model Relationships
  belongs_to :user
  belongs_to :project

  # Model Methods

  def self.searchable_attributes
    %w(name category)
  end
end
