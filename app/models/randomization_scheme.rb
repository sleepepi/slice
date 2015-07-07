class RandomizationScheme < ActiveRecord::Base

  # Triggers
  after_create :create_default_block_size_multipliers

  # Concerns
  include Searchable, Deletable

  # Named Scopes

  # Model Validation
  validates_presence_of :name, :user_id, :project_id
  validates_uniqueness_of :name, scope: [:deleted, :project_id]
  validates_numericality_of :randomization_goal, greater_than_or_equal_to: 0, only_integer: true

  # Model Relationships
  belongs_to :user
  belongs_to :project
  has_many :block_size_multipliers, -> { where deleted: false }
  has_many :treatment_arms,         -> { where deleted: false }

  # Model Methods

  private

    def create_default_block_size_multipliers
      (1..4).each do |value|
        self.block_size_multipliers.create(project_id: self.project_id, user_id: self.user_id, value: value)
      end
    end

end
