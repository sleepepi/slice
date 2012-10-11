class SheetEmail < ActiveRecord::Base
  attr_accessible :email_body, :email_cc, :email_pdf_file, :email_subject, :email_to, :sheet_id, :user_id

  mount_uploader :email_pdf_file, GenericUploader

  # Named Scopes
  scope :current, conditions: { deleted: false }

  # Model Relationships
  belongs_to :user
  belongs_to :sheet

  # Model Methods
  def destroy
    update_column :deleted, true
  end

  def email_receipt
    UserMailer.sheet_receipt(self).deliver if Rails.env.production?
    self.sheet.update_column :last_emailed_at, Time.now
  end

end
