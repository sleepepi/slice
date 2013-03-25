class Comment < ActiveRecord::Base

  # Concerns
  include Deletable

  # Named Scopes
  scope :search, lambda { |arg| where('LOWER(description) LIKE ?', arg.to_s.downcase.gsub(/^| |$/, '%')) }
  scope :with_project, lambda { |arg| where('comments.sheet_id in (select sheets.id from sheets where sheets.deleted = ? and sheets.project_id IN (?))', false, arg) }

  after_create :send_email

  # Model Validation
  validates_presence_of :description, :sheet_id, :user_id

  # Model Relationships
  belongs_to :user
  belongs_to :sheet

  def name
    "##{self.id}"
  end

  def project_id
    self.sheet.project_id
  end

  def users_to_email
    result = (self.sheet.project.users + [self.sheet.project.user] + self.sheet.subject.site.users).uniq - [self.user]
    result = result.select{|u| u.email_on?(:send_email) and u.email_on?(:sheet_comment) and u.email_on?("project_#{self.sheet.project.id}") and u.email_on?("project_#{self.sheet.project.id}_sheet_comment") }
  end

  def editable_by?(current_user)
    self.sheet.project.editable_by?(current_user)
  end

  def deletable_by?(current_user)
    self.user == current_user or self.editable_by?(current_user)
  end

  private

    def send_email
      self.users_to_email.each do |user_to_email|
        UserMailer.comment_by_mail(self, user_to_email).deliver if Rails.env.production?
      end
    end

end
