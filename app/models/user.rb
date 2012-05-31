class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable and :omniauthable
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me  # attr_accessible :title, :body
  attr_accessible :first_name, :last_name

  # Callbacks
  after_create :notify_system_admins
  before_update :status_activated

  STATUS = ["active", "denied", "inactive", "pending"].collect{|i| [i,i]}

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :status, lambda { |*args|  { conditions: ["users.status IN (?)", args.first] } }
  scope :search, lambda { |*args| { conditions: [ 'LOWER(first_name) LIKE ? or LOWER(last_name) LIKE ? or LOWER(email) LIKE ?', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }
  scope :system_admins, conditions: { system_admin: true }

  # Model Validation
  validates_presence_of :first_name, :last_name

  # Model Relationships
  has_many :authentications
  has_many :designs, conditions: { deleted: false }
  has_many :projects, conditions: { deleted: false }
  has_many :sheets, conditions: { deleted: false }
  has_many :sites, conditions: { deleted: false }
  has_many :subjects, conditions: { deleted: false }
  has_many :variables, conditions: { deleted: false }

  # User Methods
  # Overriding Devise built-in active_for_authentication? method
  def active_for_authentication?
    super and self.status == 'active' and not self.deleted?
  end

  def destroy
    update_attribute :deleted, true
    update_attribute :status, 'inactive'
  end

  # def email_on?(value)
  #   [nil, true].include?(self.email_notifications[value.to_s])
  # end

  def name
    "#{first_name} #{last_name}"
  end

  def reverse_name
    "#{last_name}, #{first_name}"
  end

  def apply_omniauth(omniauth)
    unless omniauth['info'].blank?
      self.email = omniauth['info']['email'] if email.blank?
      self.first_name = omniauth['info']['first_name'] if first_name.blank?
      self.last_name = omniauth['info']['last_name'] if last_name.blank?
    end
    authentications.build( provider: omniauth['provider'], uid: omniauth['uid'] )
  end

  def password_required?
    (authentications.empty? || !password.blank?) && super
  end

  private

  def notify_system_admins
    User.current.system_admins.each do |system_admin|
      UserMailer.notify_system_admin(system_admin, self).deliver if Rails.env.production?
    end
  end

  def status_activated
    unless self.new_record? or self.changes.blank?
      if self.changes['status'] and self.changes['status'][1] == 'active'
        UserMailer.status_activated(self).deliver if Rails.env.production?
      end
    end
  end
end
