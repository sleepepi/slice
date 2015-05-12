class Subject < ActiveRecord::Base

  STATUS = ["valid", "test"].collect{|i| [i,i]}

  # Concerns
  include Deletable

  # Named Scopes
  scope :search, lambda { |arg| where( 'LOWER(subject_code) LIKE ?', arg.to_s.downcase.gsub(/^| |$/, '%') ) }
  scope :with_project, lambda { |arg| where( project_id: arg ) }
  scope :without_design, lambda { |arg| where( "subjects.id NOT IN (select sheets.subject_id from sheets where sheets.deleted = ? and sheets.design_id IN (?))", false, arg ) }
  scope :with_design, lambda { |arg| where( "subjects.id IN (select sheets.subject_id from sheets where sheets.deleted = ? and sheets.design_id IN (?))", false, arg ) }

  # Model Validation
  validates_presence_of :project_id, :subject_code, :user_id, :site_id
  validates_uniqueness_of :subject_code, case_sensitive: false, scope: [ :deleted, :project_id ]

  def name
    self.subject_code
  end

  # Model Relationships
  belongs_to :user
  belongs_to :project
  belongs_to :site
  has_many :sheets, -> { where deleted: false }
  has_many :subject_schedules

  has_many :subject_events, -> { order(:event_date) }

  # Model Methods

  def editable_by?(current_user)
    current_user.all_subjects.where(id: self.id).count == 1
  end

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

  def self.without_design_event_schedule(subject_scope, project, design_id, event_id, schedule_id)
    if not design_id.blank? and (event_id.blank? or schedule_id.blank?)
      subject_scope = subject_scope.without_design(design_id)
    elsif not design_id.blank? and not event_id.blank? and not schedule_id.blank?
      assigned_subject_schedule_ids = SubjectSchedule.where( schedule_id: schedule_id ).pluck(:id)
      entered_subject_schedule_ids = project.sheets.where( subject_schedule_id: assigned_subject_schedule_ids, event_id: event_id, design_id: design_id ).pluck( :subject_schedule_id )
      unentered_subject_ids = SubjectSchedule.where( schedule_id: schedule_id ).where( "id NOT IN (?)", entered_subject_schedule_ids ).pluck(:subject_id)
      subject_scope = subject_scope.where( id: unentered_subject_ids )
    end

    subject_scope
  end

  def uploaded_files
    SheetVariable.where(sheet_id: self.sheets.select(:id)).includes(:variable).where(variables: { variable_type: 'file' })
  end

end
