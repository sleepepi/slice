class Site < ActiveRecord::Base

  # Concerns
  include Searchable, Deletable

  # Named Scopes
  scope :with_project, lambda { |arg| where( project_id: arg ) }
  scope :with_project_or_as_site_user, lambda { |*args| where("sites.project_id IN (?) or sites.id in (select site_users.site_id from site_users where site_users.user_id = ?)", args.first, args[1]).references(:site_users) }
  scope :with_project_or_as_site_editor, lambda { |*args| where("sites.project_id IN (?) or sites.id in (select site_users.site_id from site_users where site_users.user_id = ? and site_users.editor = ?)", args.first, args[1], true).references(:site_users) }

  # Model Validation
  validates_presence_of :name, :project_id, :user_id
  validates_uniqueness_of :name, scope: [:project_id, :deleted]
  validates_uniqueness_of :prefix, allow_blank: true, scope: [:project_id, :deleted]

  # Model Relationships
  belongs_to :user
  belongs_to :project
  has_many :subjects, -> { where deleted: false }
  has_many :site_users
  has_many :users, -> { where( deleted: false ).order( 'last_name, first_name' ) }, through: :site_users

end
