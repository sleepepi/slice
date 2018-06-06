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

  def sheets
    sheet_scope = project.sheets
    check_filters.each_with_index do |check_filter, index|
      if index.zero?
        sheet_scope = sheet_scope.where(id: check_filter.sheets.select(:id))
      else
        sheet_scope = Sheet.where(id: sheet_scope.select(:id)).or(Sheet.where(id: check_filter.sheets.select(:id)))
      end
    end
    design_ids = DesignOption.where(variable_id: check_filters.select(:variable_id)).select(:design_id)
    sheet_scope = sheet_scope.where(design_id: design_ids)
    project.sheets.where(id: sheet_scope.select(:id), subject_id: subjects.select(:id))
  end

  def subjects
    subject_scope = project.subjects
    check_filters.each do |check_filter|
      subject_scope = subject_scope.where(id: check_filter.subjects.select(:id))
    end
    subject_scope
  end

  def run!
    status_checks.destroy_all
    sheets.pluck(:id).each do |sheet_id|
      status_checks.create(sheet_id: sheet_id, failed: true)
    end
    update last_run_at: Time.zone.now
  end

  def destroy
    update slug: nil
    status_checks.destroy_all
    super
  end
end
