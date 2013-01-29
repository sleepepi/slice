class Export < ActiveRecord::Base
  attr_accessible :name, :file, :project_id, :status, :viewed, :file_created_at, :details,
                  :include_xls, :include_csv_labeled, :include_csv_raw, :include_pdf, :include_files, :include_data_dictionary #, :user_id

  mount_uploader :file, GenericUploader

  STATUS = ["ready", "pending", "failed"].collect{|i| [i,i]}

  # Concerns
  include Deletable

  # Named Scopes

  # Model Validation
  validates_presence_of :name, :user_id, :project_id

  # Model Relationships
  belongs_to :user
  belongs_to :project

  # Model Methods
  def notify_user!
    UserMailer.export_ready(self).deliver if Rails.env.production?
  end
end
