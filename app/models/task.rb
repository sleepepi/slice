# frozen_string_literal: true

# A completable project todo that is within a specific window and has a due date
class Task < ApplicationRecord
  # Concerns
  include Deletable, Searchable

  # Model Validation
  validates :project_id, :user_id, :description, :due_date, :window_start_date, :window_end_date, presence: true

  # Model Relationships
  belongs_to :project
  belongs_to :user
  has_one :randomization_task
  has_one :randomization, through: :randomization_task

  # Model Methods

  def name
    "Task ##{id}"
  end

  def move_to_date(new_due_date)
    offset = new_due_date - due_date
    update due_date: due_date + offset,
           window_start_date: window_start_date + offset,
           window_end_date: window_end_date + offset
  end

  def editable_by?(current_user)
    current_user.all_tasks.where(id: id).count == 1
  end

  # Shows tasks IF
  # Project has Blind module disabled
  # OR Task not set as Only Blinded
  # OR User is Project Owner
  # OR User is Unblinded Project Member
  # OR User is Unblinded Site Member
  def self.blinding_scope(user)
    joins(:project)
      .joins("LEFT OUTER JOIN project_users ON project_users.project_id = projects.id and project_users.user_id = #{user.id}")
      .joins("LEFT OUTER JOIN site_users ON site_users.project_id = projects.id and site_users.user_id = #{user.id}")
      .where('projects.blinding_enabled = ? or tasks.only_unblinded = ? or projects.user_id = ? or project_users.unblinded = ? or site_users.unblinded = ?', false, false, user.id, true, true)
      .distinct
  end

  def self.searchable_attributes
    %w(description)
  end

  def calendar_description
    if randomization
      "#{randomization.subject.name} #{description}"
    else
      description
    end
  end
end
