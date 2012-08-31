class Grid < ActiveRecord::Base
  attr_accessible :response, :response_file, :sheet_variable_id, :user_id, :variable_id, :position

  belongs_to :sheet_variable, touch: true
  belongs_to :variable
  belongs_to :user

  validates_presence_of :sheet_variable_id, :variable_id, :position, :user_id

  mount_uploader :response_file, GenericUploader

end
