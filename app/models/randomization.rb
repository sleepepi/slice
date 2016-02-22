# frozen_string_literal: true

class Randomization < ActiveRecord::Base
  # Serialized
  serialize :past_distributions, Hash
  serialize :weighted_eligible_arms, Array

  # Concerns
  include Deletable, Siteable, Forkable

  # Model Validation
  validates :project_id, :randomization_scheme_id, :list_id, :user_id, :block_group,
            :multiplier, :position, :treatment_arm_id, presence: true
  validates :subject_id, uniqueness: { scope: [:deleted, :project_id, :randomization_scheme_id] }, allow_nil: true
  validates :block_group, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :multiplier, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :position, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  # Model Relationships
  belongs_to :project
  belongs_to :randomization_scheme
  belongs_to :list
  belongs_to :user
  belongs_to :treatment_arm
  belongs_to :subject
  belongs_to :randomized_by, class_name: 'User', foreign_key: 'randomized_by_id'
  has_many :randomization_characteristics
  has_many :randomization_tasks
  has_many :tasks, -> { current.order(:due_date) }, through: :randomization_tasks

  # Named Scopes
  def self.blinding_scope(user)
    joins(:project)
      .joins("LEFT OUTER JOIN project_users ON project_users.project_id = projects.id and project_users.user_id = #{user.id}")
      .joins("LEFT OUTER JOIN site_users ON site_users.project_id = projects.id and site_users.user_id = #{user.id}")
      .where('projects.blinding_enabled = ? or projects.user_id = ? or project_users.unblinded = ? or site_users.unblinded = ?', false, user.id, true, true)
      .distinct
  end

  def self.year(year)
    where 'extract(year from randomizations.randomized_at) = ?', year
  end

  def self.month(month)
    where 'extract(month from randomizations.randomized_at) = ?', month
  end

  # Model Methods

  def editable_by?(current_user)
    current_user.all_randomizations.where(id: id).count == 1
  end

  def event_at
    randomized_at
  end

  def name
    randomization_number || ''
  end

  def add_subject!(subject, current_user)
    notify_users_in_background! if update subject: subject, randomized_by: current_user, randomized_at: Time.zone.now, attested: true
  end

  def randomized?
    subject_id != nil
  end

  def randomization_number
    randomization_scheme.randomizations.where.not(subject_id: nil).order(:randomized_at).pluck(:id).index(id) + 1
  rescue
    nil
  end

  def list_position
    list.randomizations.order(:created_at).pluck(:id).index(id) + 1
  rescue
    nil
  end

  def notify_users_in_background!
    fork_process(:notify_users!)
  end

  def notify_users!
    all_users = project.unblinded_members.where(emails_enabled: true) - [randomized_by]
    all_users.each do |user_to_email|
      UserMailer.subject_randomized(self, user_to_email).deliver_later if EMAILS_ENABLED
    end
  end

  def undo!
    update(
      subject_id: nil,
      randomized_at: nil,
      randomized_by_id: nil,
      attested: false,
      dice_roll: nil,
      dice_roll_cutoff: nil,
      past_distributions: nil,
      weighted_eligible_arms: nil
    )
    randomization_characteristics.destroy_all
    randomization_tasks.destroy_all
  end

  def launch_tasks!
    randomization_scheme.randomization_scheme_tasks.each do |rst|
      offset_units = %w(days weeks months years).include?(rst.offset_units) ? rst.offset_units : 'days'
      window_units = %w(days weeks).include?(rst.window_units) ? rst.window_units : 'days'
      due_date = created_at + rst.offset.send(offset_units)
      window_start_date = due_date - rst.window.send(window_units)
      window_end_date = due_date + rst.window.send(window_units)

      task = project.tasks.create(
        user_id: user_id,
        description: rst.description,
        due_date: due_date,
        window_start_date: window_start_date,
        window_end_date: window_end_date,
        only_unblinded: true
      )

      randomization_tasks.create(task_id: task.id) unless task.new_record?
    end
  end
end
