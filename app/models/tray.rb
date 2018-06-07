# frozen_string_literal: true

class Tray < ApplicationRecord
  # Concerns
  include Searchable
  include Sluggable
  include Strippable
  strip :name

  # Validations
  validates :name, presence: true
  validates :slug, format: { with: /\A[a-z][a-z0-9\-]*\Z/ },
                   exclusion: { in: %w(new edit create update destroy trays) },
                   uniqueness: { scope: :profile_id },
                   allow_nil: true
  validates :time_in_seconds, numericality: { greater_than_or_equal_to: 0 }

  # Relationships
  belongs_to :profile
  has_many :cubes, -> { order(:position) }
  has_many :tray_prints

  # Methods
  def self.searchable_attributes
    %w(name description)
  end

  def public?
    true
  end

  def major_version_number
    1
  end
end
