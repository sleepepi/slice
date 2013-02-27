class Subject < ActiveRecord::Base
  # attr_accessible :project_id, :subject_code, :user_id, :site_id, :acrostic, :email, :status

  STATUS = ["valid", "pending", "test"].collect{|i| [i,i]}

  # Concerns
  include Deletable

  # Named Scopes
  scope :search, lambda { |arg| where( 'LOWER(subject_code) LIKE ?', arg.to_s.downcase.gsub(/^| |$/, '%') ) }
  scope :with_project, lambda { |arg| where( project_id: arg ) }
  scope :with_site, lambda { |arg| where( site_id: arg ) }
  scope :without_design, lambda { |arg| where( "subjects.id NOT IN (select sheets.subject_id from sheets where sheets.deleted = ? and sheets.design_id IN (?))", false, arg ) }
  scope :with_design, lambda { |arg| where( "subjects.id IN (select sheets.subject_id from sheets where sheets.deleted = ? and sheets.design_id IN (?))", false, arg ) }

  # Model Validation
  validates_presence_of :project_id, :subject_code, :user_id, :site_id
  validates_uniqueness_of :subject_code, scope: [ :deleted, :project_id ]

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
