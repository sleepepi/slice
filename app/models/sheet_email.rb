class SheetEmail < ActiveRecord::Base

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
