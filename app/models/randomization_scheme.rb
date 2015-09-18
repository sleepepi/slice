class RandomizationScheme < ActiveRecord::Base
  # Triggers
  after_create :create_default_block_size_multipliers

  # Constants
  MAX_LISTS = 128
  ALGORITHMS = [['Permuted-Block Algorithm', 'permuted-block'], ['Minimization Algorithm', 'minimization']]

  # Concerns
  include Searchable, Deletable

  # Named Scopes
  scope :published, -> { where published: true }

  # Model Validation
  validates_presence_of :name, :user_id, :project_id
  validates_uniqueness_of :name, case_sensitive: false, scope: [:deleted, :project_id]
  validates_numericality_of :randomization_goal, greater_than_or_equal_to: 0, only_integer: true
  validates_numericality_of :chance_of_random_treatment_arm_selection, greater_than_or_equal_to: 0, less_than_or_equal_to: 100, only_integer: true

  # Model Relationships
  belongs_to :user
  belongs_to :project
  belongs_to :variable
  has_many :block_size_multipliers, -> { where(deleted: false).order(:value) }
  has_many :lists,                  -> { where deleted: false }
  has_many :randomizations,         -> { where deleted: false }
  has_many :stratification_factors, -> { where deleted: false }
  has_many :stratification_factor_options, -> { where deleted: false }
  has_many :treatment_arms,         -> { where(deleted: false).order(:name) }

  # Model Methods

  def add_missing_lists!(current_user)
    RandomizationAlgorithm.for(self).add_missing_lists!(current_user)
  end

  def generate_lists!(current_user)
    return false if self.has_randomized_subjects?
    self.randomizations.destroy_all
    self.lists.destroy_all
    self.add_missing_lists!(current_user)
    true
  end

  def find_list_by_criteria_pairs(criteria_pairs)
    RandomizationAlgorithm.for(self).find_list_by_criteria_pairs(criteria_pairs)
  end

  def randomize_subject_to_list!(subject, list, current_user, criteria_pairs)
    RandomizationAlgorithm.for(self).randomize_subject_to_list!(subject, list, current_user, criteria_pairs)
  end

  def number_of_lists
    RandomizationAlgorithm.for(self).number_of_lists
  end

  def all_criteria_selected?(criteria_pairs)
    RandomizationAlgorithm.for(self).all_criteria_selected?(criteria_pairs)
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

  def algorithm_name
    if algorithm = ALGORITHMS.select{|name, value| value == self.algorithm}.first
      algorithm[0]
    else
      "No Algorithm Selected"
    end
  end

  def permuted_block?
    self.algorithm == 'permuted-block'
  end

  def minimization?
    self.algorithm == 'minimization'
  end

  def randomization_error_message
    RandomizationAlgorithm.for(self).randomization_error_message
  end

  private

  def create_default_block_size_multipliers
    (1..4).each do |value|
      block_size_multipliers.create(project_id: project_id, user_id: user_id, value: value)
    end
  end
end
