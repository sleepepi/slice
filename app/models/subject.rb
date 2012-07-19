class Subject < ActiveRecord::Base
  attr_accessible :project_id, :subject_code, :user_id, :site_id, :validated, :acrostic

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_project, lambda { |*args| { conditions: ["subjects.project_id IN (?)", args.first] } }
  scope :with_site, lambda { |*args| { conditions: ["subjects.site_id IN (?)", args.first] } }
  scope :search, lambda { |*args| { conditions: [ 'LOWER(subject_code) LIKE ?', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }
  scope :without_design, lambda { |*args| { conditions: ["subjects.id NOT IN (select sheets.subject_id from sheets where sheets.deleted = ? and sheets.design_id IN (?))", false, args.first] } }
  scope :with_design, lambda { |*args| { conditions: ["subjects.id IN (select sheets.subject_id from sheets where sheets.deleted = ? and sheets.design_id IN (?))", false, args.first] } }
  scope :validated, lambda { |*args| { conditions: ["subjects.validated = ?", args.first] } }

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
