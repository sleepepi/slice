class Site < ActiveRecord::Base
  attr_accessible :description, :emails, :name, :project_id

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_project, lambda { |*args| { conditions: ["sites.project_id IN (?)", args.first] } }
  scope :search, lambda { |*args| { conditions: [ 'LOWER(name) LIKE ? or LOWER(description) LIKE ?', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }

  # Model Validation
  validates_presence_of :name, :project_id, :user_id
  validates_uniqueness_of :name, scope: [:project_id, :deleted]

  # Model Relationships
  belongs_to :user
  belongs_to :project

  # Model Methods
  def destroy
    update_attribute :deleted, true
  end

  def name_with_project
    [self.name, self.project.name].compact.join(' - ')
  end

end
