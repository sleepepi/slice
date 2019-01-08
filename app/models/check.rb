# frozen_string_literal: true

# Defines a check that can be run on a project to identify data inconsistencies.
class Check < ApplicationRecord
  # Concerns
  include Deletable
  include Sluggable
  include Squishable

  squish :name, :message

  # Scopes
  scope :runnable, -> { current.where(archived: false).where.not(message: [nil, ""]) }

  # Validation
  validates :name, :message, presence: true
  validates :slug, format: { with: /\A[a-z][a-z0-9\-]*\Z/ },
                   exclusion: { in: %w(new edit create update destroy) },
                   uniqueness: { scope: :project_id },
                   allow_nil: true

  # Relationships
  belongs_to :project
  belongs_to :user
  has_many :check_filters
  has_many :status_checks

  # Methods

  def run!
    status_checks.destroy_all
    interpreter.sheets.pluck(:id).each do |sheet_id|
      status_checks.create(sheet_id: sheet_id, failed: true)
    end
    update last_run_at: Time.zone.now
  end

  def destroy
    update slug: nil
    status_checks.destroy_all
    super
  end

  private

  def interpreter
    engine = ::Engine::Engine.new(project, project.user)
    engine.run(expression.to_s)
    engine.interpreter
  end
end
