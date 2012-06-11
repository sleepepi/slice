class SheetVariable < ActiveRecord::Base
  attr_accessible :response, :sheet_id, :user_id, :variable_id

  belongs_to :sheet
  belongs_to :variable
  belongs_to :user

  validates_presence_of :sheet_id, :variable_id, :user_id

end
