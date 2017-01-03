# frozen_string_literal: true

# Defines a check that can be run on a project to identify data inconsistencies.
class Check < ApplicationRecord
  # Callbacks
  after_commit :reset_checks_in_background!

  # Concerns
  include Deletable, Sluggable, Squishable, Forkable

  squish :name, :message

  # Scopes
  scope :runnable, -> { current.where(archived: false).where.not(message: [nil, '']) }

  # Validation
  validates :project_id, :user_id, :name, presence: true
  validates :slug, uniqueness: { scope: :project_id },
                   format: { with: /\A[a-z][a-z0-9\-]*\Z/ },
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
      if index == 0
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

  def reset_checks_in_background!
    fork_process :reset_checks!
  end

  def reset_checks!
    project.sheets.find_each do |sheet|
      status_checks.where(sheet_id: sheet.id).first_or_create
    end
    status_checks.update_all failed: nil
    status_checks.where(sheet_id: sheets.select(:id)).update_all failed: true
    status_checks.where(failed: nil).update_all failed: false
  end

  def destroy
    update slug: nil
    status_checks.destroy_all
    super
  end
end
