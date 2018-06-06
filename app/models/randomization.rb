# frozen_string_literal: true

# Tracks a position, list, and characteristics of a randomization.
# Randomizations can exist without having a subject as placeholders for the
# permuted-block algorithm, and are generated dynamically by the minimization
# algorithm.
class Randomization < ApplicationRecord
  # Constants
  ORDERS = {
    "scheme" => "randomization_schemes.name",
    "scheme desc" => "randomization_schemes.name desc",
    "site" => "sites.name",
    "site desc" => "sites.name desc",
    "arm" => "treatment_arms.name",
    "arm desc" => "treatment_arms.name desc",
    "randomized_by" => "users.full_name",
    "randomized_by desc" => "users.full_name desc",
    "subject" => "subjects.subject_code",
    "subject desc" => "subjects.subject_code desc",
    "randomized" => "randomizations.randomized_at nulls last",
    "randomized desc" => "randomizations.randomized_at desc nulls last"
  }
  DEFAULT_ORDER = "randomizations.randomized_at desc nulls last"

  # Serialized
  serialize :past_distributions, Hash
  serialize :weighted_eligible_arms, Array

  # Concerns
  include Blindable
  include Deletable
  include Forkable
  include Latexable
  include Siteable

  # Validations
  validates :project_id, :randomization_scheme_id, :list_id, :user_id, :block_group,
            :multiplier, :position, :treatment_arm_id, presence: true
  validates :subject_id, uniqueness: { scope: [:deleted, :project_id, :randomization_scheme_id] }, allow_nil: true
  validates :block_group, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :multiplier, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :position, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  # Relationships
  belongs_to :project
  belongs_to :randomization_scheme
  belongs_to :list
  belongs_to :user
  belongs_to :treatment_arm
  belongs_to :subject, optional: true, counter_cache: true
  belongs_to :randomized_by, optional: true, class_name: "User", foreign_key: "randomized_by_id"
  has_many :randomization_characteristics
  has_many :randomization_tasks
  has_many :tasks, -> { current.order(:due_date) }, through: :randomization_tasks

  delegate :site, to: :subject

  # Scopes
  def self.year(year)
    where "extract(year from randomizations.randomized_at) = ?", year
  end

  def self.month(month)
    where "extract(month from randomizations.randomized_at) = ?", month
  end

  # Methods

  def editable_by?(current_user)
    current_user.all_randomizations.where(id: id).count == 1
  end

  def event_at
    randomized_at
  end

  def add_subject!(subject, current_user)
    params = { subject: subject,
               randomized_by: current_user,
               randomized_at: Time.zone.now,
               attested: true }
    return unless update(params)
    notify_users_in_background!
  end

  def randomized?
    subject_id != nil
  end

  def generate_name!
    update name: randomization_number
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

  def users_to_email
    project.unblinded_members_for_site(site)
           .where.not(id: randomized_by_id)
           .where(emails_enabled: true)
           .select { |u| project.emails_enabled?(u) }
  end

  def notify_users!
    return if !EMAILS_ENABLED || project.disable_all_emails?
    users_to_email.each do |user_to_email|
      UserMailer.subject_randomized(self, user_to_email).deliver_now
    end
  end

  def undo!
    update(subject_id: nil, randomized_at: nil, randomized_by_id: nil,
           attested: false, dice_roll: nil, dice_roll_cutoff: nil,
           past_distributions: nil, weighted_eligible_arms: nil)
    randomization_characteristics.destroy_all
    randomization_tasks.destroy_all
    randomization_scheme.reset_randomization_names!
  end

  def launch_tasks!
    randomization_scheme.randomization_scheme_tasks.each do |rst|
      task = rst.create_task(randomized_at.to_date, user_id)
      randomization_tasks.create(task_id: task.id) unless task.new_record?
    end
  end

  def latex_partial(partial)
    File.read(File.join("app", "views", "randomizations", "latex", "_#{partial}.tex.erb"))
  end

  def latex_file_location(current_user)
    jobname = "randomization_#{id}"
    output_folder = File.join("tmp", "files", "tex")
    file_tex = File.join("tmp", "files", "tex", "#{jobname}.tex")
    File.open(file_tex, "w") do |file|
      file.syswrite(ERB.new(latex_partial("schedule")).result(binding))
    end
    Design.generate_pdf(jobname, output_folder, file_tex)
  end
end
