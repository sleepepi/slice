class Subject < ActiveRecord::Base

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

  def self.first_or_create_with_defaults(project, subject_code, acrostic, user, default_site, default_status)
    # (1) Find existing subject...
    subject = project.subjects.where(subject_code: subject_code).first
    return subject if subject
    # (2) if not found slot into site by subject code and set proper site or use fallback
    site = project.sites.find_by_id(project.site_id_with_prefix(subject_code))
    if site
      default_site = site
      default_status = 'valid' if site.valid_subject_code?(subject_code)
    end

    subject = project.subjects.where(subject_code: subject_code).first_or_create( acrostic: acrostic, user_id: user.id, site_id: default_site.id, status: default_status )
    subject
  end

end
