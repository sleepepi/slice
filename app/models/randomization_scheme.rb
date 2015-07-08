class RandomizationScheme < ActiveRecord::Base

  # Triggers
  after_create :create_default_block_size_multipliers

  # Constants
  MAX_LISTS = 128

  # Concerns
  include Searchable, Deletable

  # Named Scopes
  scope :published, -> { where published: true }

  # Model Validation
  validates_presence_of :name, :user_id, :project_id
  validates_uniqueness_of :name, case_sensitive: false, scope: [:deleted, :project_id]
  validates_numericality_of :randomization_goal, greater_than_or_equal_to: 0, only_integer: true

  # Model Relationships
  belongs_to :user
  belongs_to :project
  has_many :block_size_multipliers, -> { where deleted: false }
  has_many :lists,                  -> { where deleted: false }
  has_many :randomizations,         -> { where deleted: false }
  has_many :stratification_factors, -> { where deleted: false }
  has_many :stratification_factor_options, -> { where deleted: false }
  has_many :treatment_arms,         -> { where deleted: false }

  # Model Methods

  def generate_lists!(current_user)
    return if self.randomizations.where.not(subject_id: nil).size > 0
    return if self.lists.count > 0

    list_option_ids = []

    if self.number_of_lists > 0 and self.number_of_lists < MAX_LISTS
      if self.stratification_factors.count == 1
        list_option_ids = self.stratification_factors.first.stratification_factor_options.pluck(:id).collect{|i| [i]}
      else
        list_option_ids = self.stratification_factors.collect{|sf| sf.stratification_factor_options.pluck(:id)}.inject(:product)
      end
    end

    list_option_ids.each do |option_ids|
      options = self.stratification_factor_options.where(id: option_ids)
      list_name = options.pluck(:label).join(', ')
      list = self.lists.create(project_id: self.project_id, user_id: current_user.id, name: list_name)
      options.each do |option|
        list.options << option
      end
    end
  end

  def randomize_subject_to_list!(subject, list, current_user)
    # Find next randomization in list
    randomization = list.randomizations.where(subject_id: nil).order(:position).first

    # Expand lists by another block group
    unless randomization
      generate_next_block_group!(current_user)
      randomization = list.randomizations.where(subject_id: nil).order(:position).first
    end

    # Add subject to randomization list
    randomization.add_subject!(subject, current_user) if randomization
    randomization
  end

  def generate_next_block_group!(current_user)
    block_group = (self.randomizations.pluck(:block_group).max + 1 rescue 0)

    multipliers = self.block_size_multipliers.collect{|m| [m.value] * m.allocation }.flatten
    self.lists.each do |list|
      list_position = (list.randomizations.pluck(:position).max + 1 rescue 0)
      multipliers.shuffle.each do |multiplier|
        (self.treatment_arms.collect{|arm| [arm.id] * arm.allocation }.flatten * multiplier).shuffle.each do |treatment_arm_id|
          self.randomizations.create(
            project_id: self.project_id,
            list_id: list.id,
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
  end

  def number_of_lists
    self.stratification_factors.collect{ |sf| sf.stratification_factor_options.count }.inject(:*).to_i
  end

  def minimum_block_size
    self.treatment_arms.pluck(:allocation).sum
  end

  def randomization_requirements
    # "By checking this box I attest that I have personally entered all of the available data recorded and reviewed for completeness and accuracy. All information entered by me is correct to the best of my knowledge."
  end

  private

    def create_default_block_size_multipliers
      (1..4).each do |value|
        self.block_size_multipliers.create(project_id: self.project_id, user_id: self.user_id, value: value)
      end
    end

end
