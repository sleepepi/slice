# frozen_string_literal: true

# Creates a template for a task for a randomization scheme.
class RandomizationSchemeTask < ApplicationRecord
  # Relationships
  belongs_to :randomization_scheme

  delegate :project, to: :randomization_scheme

  # Methods

  def create_task(base_date, user_id)
    project.tasks.create(
      user_id: user_id,
      description: description,
      due_date: due_date(base_date),
      window_start_date: window_start_date(base_date),
      window_end_date: window_end_date(base_date),
      only_unblinded: true
    )
  end

  def due_date(base_date)
    if randomization_scheme.allow_tasks_on_weekends?
      base_date + day_offset
    else
      closest_weekday(base_date + day_offset)
    end
  end

  def window_start_date(base_date)
    due_date(base_date) - window_range
  end

  def window_end_date(base_date)
    due_date(base_date) + window_range
  end

  # Calculates the offset from initial date using `offset` and `offset_units`
  def day_offset
    offset.send(clean_offset_units)
  end

  # Calculates the window range from initial date using `window` and
  # `window_units`
  def window_range
    window.send(clean_window_units)
  end

  def clean_offset_units
    %w(days weeks months years).include?(offset_units) ? offset_units : "days"
  end

  def clean_window_units
    %w(days weeks).include?(window_units) ? window_units : "days"
  end

  def closest_weekday(date)
    if date.saturday?
      date - 1.day
    elsif date.sunday?
      date + 1.day
    else
      date
    end
  end
end
