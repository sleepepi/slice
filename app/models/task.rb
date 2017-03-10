# frozen_string_literal: true

# A completable project todo that is within a specific window and has a due date
class Task < ApplicationRecord
  # Concerns
  include Deletable, Searchable, Blindable

  # Validations
  validates :project_id, :user_id, :description, :due_date, :window_start_date, :window_end_date, presence: true

  # Relationships
  belongs_to :project
  belongs_to :user
  has_one :randomization_task
  has_one :randomization, through: :randomization_task

  # Methods

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

  def phonecall?
    !(description =~ /phone/i).nil?
  end

  def visit?
    !(description =~ /visit/i).nil?
  end
end
