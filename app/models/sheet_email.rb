class SheetEmail < ActiveRecord::Base
  attr_accessible :email_body, :email_cc, :email_pdf_file, :email_subject, :email_to, :sheet_id, :user_id

  mount_uploader :email_pdf_file, GenericUploader

  # Concerns
  include Deletable

  # Named Scopes

  # Model Relationships
  belongs_to :user
  belongs_to :sheet

  # Model Methods
  def email_receipt
    UserMailer.sheet_receipt(self).deliver if Rails.env.production?
  end
end
