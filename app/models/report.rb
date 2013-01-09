class Report < ActiveRecord::Base
  attr_accessible :name, :options

  serialize :options, Hash

  # Concerns
  include Deletable

  # Named Scopes

  # Model Validation
  validates_presence_of :user_id, :name

  # Model Relationships
  belongs_to :user

  # Model Methods
  def design
    Design.current.find_by_id(self.options[:design_id])
  end

  def project
    self.design ? self.design.project : nil
  end
end
