# frozen_string_literal: true

class Subject < ActiveRecord::Base
  # Concerns
  include Searchable, Deletable

  # Named Scopes
  scope :with_project, -> (arg) { where(project_id: arg) }
  scope :without_design, -> (arg) { where('subjects.id NOT IN (select sheets.subject_id from sheets where sheets.deleted = ? and sheets.design_id IN (?))', false, arg) }
  scope :with_design, -> (arg) { where('subjects.id IN (select sheets.subject_id from sheets where sheets.deleted = ? and sheets.design_id IN (?))', false, arg) }
  scope :without_event, -> (event) { where('subjects.id NOT IN (select subject_events.subject_id from subject_events where subject_events.event_id IN (?))', event) }
  scope :with_event, -> (event) { where('subjects.id IN (select subject_events.subject_id from subject_events where subject_events.event_id IN (?))', event) }
  scope :with_entered_design_on_event, -> (design, event) { where('subjects.id IN (select subject_events.subject_id from subject_events where subject_events.event_id = ? and subject_events.id IN (SELECT sheets.subject_event_id from sheets where sheets.deleted = ? and sheets.design_id = ? and sheets.subject_event_id IS NOT NULL))', event, false, design) }
  scope :with_unentered_design_on_event, -> (design, event) { where('subjects.id IN (select subject_events.subject_id from subject_events where subject_events.event_id = ? and subject_events.id NOT IN (SELECT sheets.subject_event_id from sheets where sheets.deleted = ? and sheets.design_id = ? and sheets.subject_event_id IS NOT NULL))', event, false, design) }
  scope :without_design_on_event, -> (design, event) { where('subjects.id NOT IN (select subject_events.subject_id from subject_events where subject_events.event_id = ? and subject_events.id IN (SELECT sheets.subject_event_id from sheets where sheets.deleted = ? and sheets.design_id = ?))', event, false, design) }
  # scope :with_variable, lambda {|variable_id, value| where("subjects.id IN (select sheets.subject_id from sheets where sheets.deleted = ? and sheets.id IN (select sheet_variables.sheet_id from sheet_variables where variable_id = ? and response IN (?)))", false, variable_id, value)}

  # Model Validation
  validates :project_id, :subject_code, :site_id, presence: true
  validates :subject_code, uniqueness: { case_sensitive: false, scope: [:deleted, :project_id] }
  # validates :subject_code, validate_subject_format: { with: -> (s) { s.site.subject_regex }, message: -> (s,value) { "#{self.name} #{value} must be in valid format" } }, if: :site_regex_code?
  validate :validate_subject_format

  def name
    subject_code
  end

  # Model Relationships
  belongs_to :user
  belongs_to :project
  belongs_to :site
  has_many :adverse_events, -> { where deleted: false }
  has_many :randomizations, -> { where deleted: false }
  has_many :sheets, -> { where deleted: false }
  has_many :subject_events, -> { order :event_date }

  # Model Methods

  def self.searchable_attributes
    %w(subject_code)
  end

  def blinded_comments(current_user)
    Comment.current.where(sheet_id: blinded_sheets(current_user).select(:id))
  end

  def editable_by?(current_user)
    current_user.all_subjects.where(id: id).count == 1
  end

  def self.first_or_create_with_defaults(project, subject_code, site_name, user, default_site)
    # (1) Find existing subject...
    subject = project.subjects.where(subject_code: subject_code).first
    return subject if subject
    # (2) if not found slot into site by subject code and set proper site or use fallback
    site = project.sites.find_by_name(site_name)
    default_site = site if site

    subject = project.subjects.where(subject_code: subject_code).first_or_create(user_id: user.id, site_id: default_site.id)
    subject
  end

  def new_digest_subject?(sheet_ids)
    sheets.where.not(id: sheet_ids).count == 0
  end

  def uploaded_files(current_user)
    SheetVariable.where(sheet_id: blinded_sheets(current_user).select(:id)).includes(:variable).where(variables: { variable_type: 'file' }).order(created_at: :desc)
  end

  def has_value?(variable, value)
    sheets.joins(:sheet_variables).where(sheet_variables: { variable_id: variable.id, response: value }).count >= 1
  end

  def blinded_sheets(current_user)
    current_user.all_viewable_sheets.where(subject_id: id)
  end

  def validate_subject_format
    if user && site && site.subject_regex.present? && site.subject_regex !~ subject_code
      errors[:base] << "#{project.subject_code_name_full} must be in the following format: #{site.regex_string}"
    end
  end
end
