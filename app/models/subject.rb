class Subject < ActiveRecord::Base

  STATUS = ["valid", "test"].collect{|i| [i,i]}

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
  has_many :subject_schedules

  # Model Methods

  def self.first_or_create_with_defaults(project, subject_code, acrostic, user, default_site, default_status)
    # (1) Find existing subject...
    subject = project.subjects.where(subject_code: subject_code).first
    return subject if subject
    # (2) if not found slot into site by subject code and set proper site or use fallback
    site = project.sites.find_by_id(project.site_id_with_prefix(subject_code))
    if site
      default_site = site
      default_status = 'valid'
    end

    subject = project.subjects.where(subject_code: subject_code).first_or_create( acrostic: acrostic, user_id: user.id, site_id: default_site.id, status: default_status )
    subject
  end

  def new_digest_subject?(sheet_ids)
    self.sheets.where("sheets.id NOT IN (?)", sheet_ids).count == 0
  end

  def subject_schedule_events(design_id)
    result = []
    self.subject_schedules.each do |subject_schedule|
      subject_schedule.schedule.items.each do |item|
        item_design_ids = (item[:design_ids] || [])
        event = self.project.events.find_by_id(item[:event_id])
        event_date = subject_schedule.initial_due_date.strftime(" &middot; %a, %B %d, %Y").html_safe unless subject_schedule.initial_due_date.blank?
        result << ["#{subject_schedule.name} &middot; #{event.name}#{event_date}".html_safe, "#{subject_schedule.id}-#{event.id}"] if event and item_design_ids.include?(design_id.to_s)
      end
    end
    result
  end

end
