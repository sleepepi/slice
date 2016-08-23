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
  has_many :check_filters

  # Methods
  def sheets(current_user)
    sheet_scope = Sheet
    check_filters.each_with_index do |check_filter, index|
      if index == 0
        sheet_scope = sheet_scope.where(id: check_filter.sheets(current_user).select(:id))
      else
        sheet_scope = Sheet.where(id: sheet_scope.select(:id)).or(Sheet.where(id: check_filter.sheets(current_user).select(:id)))
      end
    end
    current_user.all_viewable_sheets.where(project: project).where(id: sheet_scope.select(:id), subject_id: subjects(current_user).select(:id))
  end

  def subjects(current_user)
    subject_scope = Subject
    check_filters.each do |check_filter|
      subject_scope = subject_scope.where(id: check_filter.subjects(current_user).select(:id))
    end
    subject_scope
  end

  def destroy
    update slug: nil
    super
  end
end
