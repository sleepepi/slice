# frozen_string_literal: true

# A site groups subjects together and helps filter subjects and sheets for site
# members, and reports that are stratified by site.
class Site < ApplicationRecord
  # Concerns
  include Searchable, Deletable, ShortNameable

  # Scopes
  def self.with_project_or_as_site_user(project_ids, user_id)
    where('sites.project_id IN (?) or sites.id in (select site_users.site_id '\
      'from site_users where site_users.user_id = ?)', project_ids, user_id)
      .references(:site_users)
  end

  def self.with_project_or_as_site_editor(project_ids, user_id)
    where('sites.project_id IN (?) or sites.id in (select site_users.site_id '\
      'from site_users where site_users.user_id = ? and site_users.editor = ?)',
          project_ids, user_id, true)
      .references(:site_users)
  end

  # Model Validation
  validates :name, :project_id, :user_id, presence: true
  validates :name, uniqueness: { scope: [:project_id, :deleted] }
  validates :subject_code_format,
            format: { with: /\A((\\d)|(\\l)|(\\L)|[a-zA-Z0-9])*\Z/ },
            allow_blank: true

  # Model Relationships
  belongs_to :user
  belongs_to :project
  has_many :expected_randomizations
  has_many :subjects, -> { current }
  has_many :site_users
  has_many :users, -> { current.order(:last_name, :first_name) }, through: :site_users

  def regex_string
    subject_code_format
      .to_s
      .gsub('\d', '[0-9]')
      .gsub('\l', '[a-z]')
      .gsub('\L', '[A-Z]')
  end

  def subject_regex
    Regexp.new("\\A#{regex_string}\\Z") if regex_string.present?
  end

  def destroy
    subjects.destroy_all
    super
  end
end
