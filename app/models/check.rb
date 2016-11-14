# frozen_string_literal: true

# Defines a check that can be run on a project to identify data inconsistencies.
class Check < ApplicationRecord
  # Concerns
  include Deletable, Sluggable, Squishable

  squish :name, :message

  # Scopes
  scope :runnable, -> { where(archived: false).where.not(message: [nil, '']) }

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

  def sheets(current_user)
    sheet_scope = project.sheets
    check_filters.each_with_index do |check_filter, index|
      if index == 0
        sheet_scope = sheet_scope.where(id: check_filter.sheets(current_user).select(:id))
      else
        sheet_scope = Sheet.where(id: sheet_scope.select(:id)).or(Sheet.where(id: check_filter.sheets(current_user).select(:id)))
      end
    end
    design_ids = DesignOption.where(variable_id: check_filters.select(:variable_id)).select(:design_id)
    sheet_scope = sheet_scope.where(design_id: design_ids)
    current_user.all_viewable_sheets.where(project: project).where(id: sheet_scope.select(:id), subject_id: subjects(current_user).select(:id))
  end

  def subjects(current_user)
    subject_scope = project.subjects
    check_filters.each do |check_filter|
      subject_scope = subject_scope.where(id: check_filter.subjects(current_user).select(:id))
    end
    subject_scope
  end

  # TODO: Remove reference to project user.
  def run_pending_checks!
    status_checks.update_all failed: nil
    status_checks.where(sheet_id: sheets(project.user).select(:id)).update_all failed: true
    status_checks.where(failed: nil).update_all failed: false
  end

  def destroy
    update slug: nil
    status_checks.destroy_all
    super
  end
end
