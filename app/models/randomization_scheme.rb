# frozen_string_literal: true

# Defines a method for randomization, either Permuted-Block or Minimization.
class RandomizationScheme < ApplicationRecord
  # Triggers
  after_create_commit :create_default_block_size_multipliers
  attr_accessor :task_hashes, :expected_randomizations_hashes
  after_save :set_tasks, :set_expected_randomizations

  # Constants
  MAX_LISTS = 512
  ALGORITHMS = [
    ["Permuted-Block Algorithm", "permuted-block"],
    ["Minimization Algorithm", "minimization"],
    ["Pre-made Custom List", "custom-list"]
  ]

  # Concerns
  include Deletable
  include Searchable

  # Scopes
  scope :published, -> { where published: true }

  # Validations
  validates :name, :user_id, :project_id, presence: true
  validates :name, uniqueness: { case_sensitive: false, scope: [:deleted, :project_id] }
  validates :randomization_goal,
            numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :chance_of_random_treatment_arm_selection,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100, only_integer: true }
  validate :minimization_must_have_stratification_factors

  # Relationships
  belongs_to :user
  belongs_to :project
  belongs_to :variable, optional: true
  has_many :expected_randomizations
  has_many :block_size_multipliers,        -> { current.order(:value) }
  has_many :lists,                         -> { current }
  has_many :randomizations,                -> { current }
  has_many :randomization_scheme_tasks,    -> { order :position }
  has_many :stratification_factors,        -> { current }
  has_many :stratification_factor_options, -> { current }
  has_many :treatment_arms,                -> { current.order(:name) }

  # Methods

  def add_missing_lists!(current_user)
    RandomizationAlgorithm.for(self).add_missing_lists!(current_user)
  end

  def generate_lists!(current_user)
    return false if randomized_subjects?

    randomizations.destroy_all
    lists.destroy_all
    add_missing_lists!(current_user)
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
    treatment_arms.pluck(:allocation).sum
  end

  def randomization_requirements
    # "By checking this box I attest that I have personally entered all of the
    #   available data recorded and reviewed for completeness and accuracy. All
    #   information entered by me is correct to the best of my knowledge."
  end

  def randomized_subjects?
    active_randomizations.count > 0
  end

  def active_randomizations
    randomizations.where.not(subject_id: nil)
  end

  def algorithm_name
    name_value = ALGORITHMS.find { |_name, value| value == algorithm }
    if name_value
      name_value[0]
    else
      "No Algorithm Selected"
    end
  end

  def permuted_block?
    algorithm == "permuted-block"
  end

  def minimization?
    algorithm == "minimization"
  end

  def custom_list?
    algorithm == "custom-list"
  end

  def randomization_error_message
    RandomizationAlgorithm.for(self).randomization_error_message
  end

  def stratification_factors_with_calculation
    stratification_factors
      .where(stratifies_by_site: false)
      .where.not(calculation: ["", nil])
  end

  def expected_recruitment_by_month(site)
    expected_randomization = expected_randomizations.where(site_id: site.id).first_or_create
    expected_randomization.expected.to_s.split(",").reject(&:blank?).collect(&:to_i)
  end

  def reset_randomization_names!
    randomizations.update_all(name: nil)
    randomizations.where.not(subject_id: nil).order(:randomized_at).each_with_index do |randomization, index|
      randomization.update name: index + 1
    end
  end

  private

  def create_default_block_size_multipliers
    (1..4).each do |value|
      block_size_multipliers.create(project_id: project_id, user_id: user_id, value: value)
    end
  end

  def set_tasks
    return unless task_hashes && task_hashes.is_a?(Array)
    randomization_scheme_tasks.destroy_all
    task_hashes.each_with_index do |hash, index|
      randomization_scheme_tasks.create(
        description: hash[:description].to_s.strip,
        offset: hash[:offset].to_i, offset_units: hash[:offset_units],
        window: hash[:window].to_i, window_units: hash[:window_units],
        position: index
      ) unless hash[:description].to_s.strip.blank?
    end
  end

  def set_expected_randomizations
    return unless expected_randomizations_hashes && expected_randomizations_hashes.is_a?(Array)
    expected_randomizations_hashes.each do |hash|
      site = project.sites.find_by(id: hash[:site_id])
      next unless site
      expected = hash[:expected].to_s.gsub(/[^\d,]/, "").split(",").reject(&:blank?).join(",")
      expected_randomization = expected_randomizations.where(site_id: site.id).first_or_create
      expected_randomization.update expected: expected
    end
  end

  def minimization_must_have_stratification_factors
    return unless published? && minimization? && stratification_factors.where(stratifies_by_site: false).count == 0
    errors.add(:published, "missing stratification factors")
  end
end
