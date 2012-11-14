class Project < ActiveRecord::Base
  attr_accessible :description, :name, :emails, :acrostic_enabled, :logo, :logo_uploaded_at, :logo_cache, :subject_code_name, :show_contacts, :show_documents, :show_posts

  mount_uploader :logo, ImageUploader

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_user, lambda { |*args| { conditions: ['projects.user_id IN (?)', args.first] } }
  scope :with_librarian, lambda { |*args| { conditions: ['projects.user_id IN (?) or projects.id in (select project_users.project_id from project_users where project_users.user_id = ? and project_users.librarian IN (?))', args.first, args.first, args[1]] } }
  scope :search, lambda { |*args| { conditions: [ 'LOWER(name) LIKE ? or LOWER(description) LIKE ?', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }

  # Model Validation
  validates_presence_of :name, :user_id
  validates_uniqueness_of :name, scope: :deleted

  # Model Relationships
  belongs_to :user

  has_many :project_users
  has_many :users, through: :project_users, conditions: { deleted: false }, order: 'last_name, first_name'
  has_many :librarians, through: :project_users, source: :user, conditions: ['project_users.librarian = ? and users.deleted = ?', true, false]
  has_many :members, through: :project_users, source: :user, conditions: ['project_users.librarian = ? and users.deleted = ?', false, false]

  has_many :designs, conditions: { deleted: false }
  has_many :variables, conditions: { deleted: false }
  has_many :sheets, conditions: { deleted: false }
  has_many :sites, conditions: { deleted: false }
  has_many :subjects, conditions: { deleted: false }

  has_many :exports, conditions: { deleted: false }

  has_many :contacts, conditions: { deleted: false }
  has_many :documents, conditions: { deleted: false }
  has_many :posts, conditions: { deleted: false }

  has_many :domains, conditions: { deleted: false }

  # Model Methods

  def sites_with_range
    self.sites.where("sites.code_minimum IS NOT NULL and sites.code_minimum != '' and sites.code_maximum IS NOT NULL and sites.code_maximum != ''").order('name')
  end

  def site_id_with_prefix(prefix)
    prefix_sites = self.sites.select{|s| not s.prefix.blank? and prefix.start_with?(s.prefix) }
    prefix_sites.size == 1 ? prefix_sites.first.id : nil
  end

  def subject_code_name_full
    self.subject_code_name.to_s.strip.blank? ? 'Subject Code' : self.subject_code_name.to_s.strip
  end

  def custom_reports
    []
  end

  # Model Methods
  def destroy
    update_column :deleted, true
  end
end
