class Site < ActiveRecord::Base
  attr_accessible :description, :emails, :name, :project_id, :prefix, :code_minimum, :code_maximum

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_project, lambda { |*args| { conditions: ["sites.project_id IN (?)", args.first] } }
  scope :with_project_or_as_site_user, lambda { |*args| { conditions: ["sites.project_id IN (?) or sites.id in (select site_users.site_id from site_users where site_users.user_id = ?)", args.first, args[1]] } }
  scope :search, lambda { |*args| { conditions: [ 'LOWER(name) LIKE ? or LOWER(description) LIKE ?', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }

  # Model Validation
  validates_presence_of :name, :project_id, :user_id
  validates_uniqueness_of :name, scope: [:project_id, :deleted]
  validates_uniqueness_of :prefix, allow_blank: true, scope: [:project_id, :deleted]

  # Model Relationships
  belongs_to :user
  belongs_to :project
  has_many :subjects, conditions: { deleted: false }
  has_many :site_users
  has_many :users, through: :site_users, conditions: { deleted: false }, order: 'last_name, first_name'

  # Model Methods
  def destroy
    update_column :deleted, true
  end

  def name_with_project
    [self.name, self.project.name].compact.join(' - ')
  end

  def valid_subject_code?(subject_code)
    subject_code <= "#{self.prefix}#{self.code_maximum}" && subject_code.size <= "#{self.prefix}#{self.code_maximum}".size && subject_code >= "#{self.prefix}#{self.code_minimum}" && subject_code.size >= "#{self.prefix}#{self.code_minimum}".size
  end

end
