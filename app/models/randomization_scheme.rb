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

  def add_missing_lists!(current_user)
    list_option_ids = []

    if self.number_of_lists > 0 and self.number_of_lists < MAX_LISTS
      if self.stratification_factors.count == 1
        list_option_ids = self.stratification_factors.first.stratification_factor_options.pluck(:id).collect{|i| [i]}
      else
        list_option_ids = self.stratification_factors.collect{|sf| sf.stratification_factor_options.pluck(:id)}.inject(:product)
      end
    end

    list_option_ids.each do |option_ids|
      unless self.find_list_by_option_ids(option_ids)
        self.lists.create(project_id: self.project_id, user_id: current_user.id, options: self.stratification_factor_options.where(id: option_ids))
      end
    end
  end

  def generate_lists!(current_user)
    return false if self.has_randomized_subjects?
    self.randomizations.destroy_all
    self.lists.destroy_all
    self.add_missing_lists!(current_user)
    true
  end

  def find_list_by_option_ids(option_ids)
    list = nil
    self.lists.each do |l|
      if l.options.pluck(:id).sort == option_ids.collect(&:to_i).sort
        list = l
        break
      end
    end
    list
  end

  def randomize_subject_to_list!(subject, list, current_user)
    # Find next randomization in list
    randomization = list.randomizations.where(subject_id: nil).order(:position).first

    # Expand lists by another block group
    unless randomization
      max_needed_block_group = [self.next_block_group - 1, list.next_block_group].max
      generate_next_block_group_up_to!(current_user, max_needed_block_group)
      randomization = list.randomizations.where(subject_id: nil).order(:position).first
    end

    # Add subject to randomization list
    randomization.add_subject!(subject, current_user) if randomization
    randomization
  end

  def generate_next_block_group_up_to!(current_user, block_group)
    multipliers = self.block_size_multipliers.collect{|m| [m.value] * m.allocation }.flatten
    arms        = self.treatment_arms.collect{|arm| [arm.id] * arm.allocation }.flatten
    self.lists.each do |list|
      list.generate_all_block_groups_up_to!(current_user, block_group, multipliers, arms)
    end
  end

  def next_block_group
    (randomizations.pluck(:block_group).max || 0) + 1
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

  def has_randomized_subjects?
    self.randomizations.where.not(subject_id: nil).count > 0
  end

  private

    def create_default_block_size_multipliers
      (1..4).each do |value|
        self.block_size_multipliers.create(project_id: self.project_id, user_id: self.user_id, value: value)
      end
    end

end
