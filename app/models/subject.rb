class Subject < ActiveRecord::Base
  # attr_accessible :project_id, :subject_code, :user_id, :site_id, :acrostic, :email, :status

  STATUS = ["valid", "pending", "test"].collect{|i| [i,i]}

  # Concerns
  include Deletable

  # Named Scopes
  scope :search, lambda { |arg| { conditions: [ 'LOWER(subject_code) LIKE ?', arg.to_s.downcase.gsub(/^| |$/, '%') ] } }
  scope :with_project, lambda { |*args| { conditions: ["subjects.project_id IN (?)", args.first] } }
  scope :with_site, lambda { |*args| { conditions: ["subjects.site_id IN (?)", args.first] } }
  scope :without_design, lambda { |*args| { conditions: ["subjects.id NOT IN (select sheets.subject_id from sheets where sheets.deleted = ? and sheets.design_id IN (?))", false, args.first] } }
  scope :with_design, lambda { |*args| { conditions: ["subjects.id IN (select sheets.subject_id from sheets where sheets.deleted = ? and sheets.design_id IN (?))", false, args.first] } }

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
  has_many :sheets, -> { where deleted: false }

  # Model Methods

end
