class Variable < ActiveRecord::Base
  attr_accessible :description, :header, :name, :response, :values, :variable_type

  TYPE = ['dropdown', 'checkbox', 'radio', 'string', 'text', 'integer', 'numeric', 'date', 'file'].collect{|i| [i,i]}

  # Named Scopes
  scope :current, conditions: { deleted: false }

  # Model Validation
  validates_presence_of :name, :variable_type
  validates_uniqueness_of :name, scope: [:deleted, :project_id]

  # Model Relationships
  belongs_to :user
  belongs_to :project
  has_and_belongs_to_many :sheets, conditions: { deleted: false }

  # Model Methods
  def destroy
    update_attribute :deleted, true
  end
end
