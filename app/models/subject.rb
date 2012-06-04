class Subject < ActiveRecord::Base
  attr_accessible :project_id, :subject_code, :user_id, :site_id

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :search, lambda { |*args| { conditions: [ 'LOWER(subject_code) LIKE ?', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }

  # Model Validation
  validates_presence_of :project_id, :subject_code, :user_id, :site_id
  validates_uniqueness_of :subject_code, scope: [:deleted, :project_id]

  def name
    self.subject_code
  end

  # Model Relationships
  belongs_to :user
  belongs_to :project
  belongs_to :site
  has_many :sheets, conditions: { deleted: false }

  # Model Methods
  def destroy
    update_attribute :deleted, true
  end
end
