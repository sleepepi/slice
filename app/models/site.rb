class Site < ActiveRecord::Base

  # Concerns
  include Searchable, Deletable

  # Named Scopes
  scope :with_project, lambda { |arg| where( project_id: arg ) }
  scope :with_project_or_as_site_user, lambda { |*args| where("sites.project_id IN (?) or sites.id in (select site_users.site_id from site_users where site_users.user_id = ?)", args.first, args[1]) }

  # Model Validation
  validates_presence_of :name, :project_id, :user_id
  validates_uniqueness_of :name, scope: [:project_id, :deleted]
  validates_uniqueness_of :prefix, allow_blank: true, scope: [:project_id, :deleted]

  # Model Relationships
  belongs_to :user
  belongs_to :project
  has_many :subjects, -> { where deleted: false }
  has_many :site_users
  has_many :users, -> { where deleted: false }, through: :site_users, order: 'last_name, first_name'

  # Model Methods
  def valid_subject_code?(subject_code)
    subject_code <= "#{self.prefix}#{self.code_maximum}" && subject_code.size <= "#{self.prefix}#{self.code_maximum}".size && subject_code >= "#{self.prefix}#{self.code_minimum}" && subject_code.size >= "#{self.prefix}#{self.code_minimum}".size
  end

end
