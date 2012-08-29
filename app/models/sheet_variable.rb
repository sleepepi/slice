class SheetVariable < ActiveRecord::Base
  attr_accessible :response, :sheet_id, :user_id, :variable_id, :response_file, :response_file_uploaded_at, :response_file_cache

  belongs_to :sheet, touch: true
  belongs_to :variable
  belongs_to :user

  validates_presence_of :sheet_id, :variable_id, :user_id

  mount_uploader :response_file, GenericUploader

end
