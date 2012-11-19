class Export < ActiveRecord::Base
  attr_accessible :export_type, :file, :include_files, :name, :project_id, :status, :viewed, :file_created_at, :details #, :user_id

  mount_uploader :file, GenericUploader

  STATUS = ["ready", "pending", "failed"].collect{|i| [i,i]}
  TYPE = ['sheets', 'designs'].collect{|i| [i,i]}

  # Named Scopes
  scope :current, conditions: { deleted: false }

  # Model Validation
  validates_presence_of :name, :user_id, :project_id

  # Model Relationships
  belongs_to :user
  belongs_to :project

  # Model Methods
  def destroy
    update_column :deleted, true
  end

  def notify_user!
    UserMailer.export_ready(self).deliver if Rails.env.production?
  end

end
