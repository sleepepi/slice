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
  def compute(current_user)
    sheet_scope = current_user.all_viewable_sheets.where(project: project)
    check_filters.each do |check_filter|
      sheet_scope = sheet_scope.where(id: check_filter.compute(current_user).select(:id))
    end
    sheet_scope
  end

  def destroy
    update slug: nil
    super
  end
end
