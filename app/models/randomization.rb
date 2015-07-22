class Randomization < ActiveRecord::Base

  # Serialized
  serialize :past_distributions, Hash
  serialize :weighted_eligible_arms, Array

  # Concerns
  include Deletable

  # Named Scopes
  scope :with_site, lambda { |arg| where("randomizations.subject_id IN (select subjects.id from subjects where subjects.deleted = ? and subjects.site_id IN (?))", false, arg).references(:subjects) }

  # Model Validation
  validates_presence_of :project_id, :randomization_scheme_id, :list_id, :user_id, :block_group, :multiplier, :position, :treatment_arm_id

  validates_uniqueness_of :subject_id, allow_nil: true, scope: [:deleted, :project_id, :randomization_scheme_id]
  validates_numericality_of :block_group, greater_than_or_equal_to: 0, only_integer: true
  validates_numericality_of :multiplier, greater_than_or_equal_to: 0, only_integer: true
  validates_numericality_of :position, greater_than_or_equal_to: 0, only_integer: true

  # Model Relationships
  belongs_to :project
  belongs_to :randomization_scheme
  belongs_to :list
  belongs_to :user
  belongs_to :treatment_arm
  belongs_to :subject
  belongs_to :randomized_by, class_name: 'User', foreign_key: 'randomized_by_id'
  has_many :randomization_characteristics

  # Model Methods

  def editable_by?(current_user)
    current_user.all_randomizations.where(id: self.id).count == 1
  end

  def event_at
    self.randomized_at
  end

  def name
    self.randomization_number || ""
  end

  def add_subject!(subject, current_user)
    if self.update subject: subject, randomized_by: current_user, randomized_at: Time.zone.now, attested: true
      self.notify_users!
    end
  end

  def randomized?
    self.subject_id != nil
  end

  def randomization_number
    self.randomization_scheme.randomizations.where.not(subject_id: nil).order(:randomized_at).pluck(:id).index(self.id) + 1 rescue nil
  end

  def list_position
    self.list.randomizations.order(:created_at).pluck(:id).index(self.id) + 1 rescue nil
  end

  def notify_users!
    unless Rails.env.test?
      pid = Process.fork
      if pid.nil? then
        # In child
        all_users = self.project.users_to_email - [self.randomized_by]
        all_users.each do |user_to_email|
          UserMailer.subject_randomized(self, user_to_email).deliver_later if Rails.env.production?
        end
        Kernel.exit!
      else
        # In parent
        Process.detach(pid)
      end
    end
  end

  def undo!
    self.update(
      subject_id: nil,
      randomized_at: nil,
      randomized_by_id: nil,
      attested: false,
      dice_roll: nil,
      dice_roll_cutoff: nil,
      past_distributions: nil,
      weighted_eligible_arms: nil
    )
    self.randomization_characteristics.destroy_all
  end

end
