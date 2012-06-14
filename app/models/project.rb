class Project < ActiveRecord::Base
  attr_accessible :description, :name, :emails

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
  has_many :sheets, conditions: { deleted: false }
  has_many :sites, conditions: { deleted: false }
  has_many :subjects, conditions: { deleted: false }

  def site_id_with_prefix(prefix)
    prefix_sites = self.sites.select{|s| not s.prefix.blank? and prefix.start_with?(s.prefix) }
    prefix_sites.size == 1 ? prefix_sites.first.id : nil
  end

  # Model Methods
  def destroy
    update_attribute :deleted, true
  end
end
