class List < ActiveRecord::Base

  # Concerns
  include Deletable

  # Named Scopes

  # Model Validation
  validates_presence_of :project_id, :randomization_scheme_id, :user_id

  # Model Relationships
  belongs_to :project
  belongs_to :randomization_scheme
  belongs_to :user
  has_many :list_options
  has_many :options, through: :list_options
  has_many :randomizations, -> { where deleted: false }

  # Model Methods

  def name
    self.list_options.includes(:option).collect(&:name).join(', ')
  end

  def subject_randomizations
    self.randomizations.where.not(subject_id: nil)
  end

  def generate_all_block_groups_up_to!(current_user, max_block_group, multipliers, arms)
    current_block_group = self.next_block_group
    (current_block_group..max_block_group).each do |block_group|
      self.generate_block_group!(current_user, block_group, multipliers, arms)
    end
  end

  def generate_block_group!(current_user, block_group, multipliers, arms)
    list_position = self.next_list_position
    multipliers.shuffle.each do |multiplier|
      (arms * multiplier).shuffle.each do |treatment_arm_id|
        self.randomizations.create(
          project_id: self.project_id,
          randomization_scheme_id: self.randomization_scheme_id,
          user_id: current_user.id,
          position: list_position,
          treatment_arm_id: treatment_arm_id,
          block_group: block_group,
          multiplier: multiplier
        )
        list_position += 1
      end
    end
  end

  def next_list_position
    (randomizations.pluck(:position).max || 0) + 1
  end

  def next_block_group
    (randomizations.pluck(:block_group).max || 0) + 1
  end

end
