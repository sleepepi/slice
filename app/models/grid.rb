class Grid < ActiveRecord::Base
  # attr_accessible :response, :response_file, :response_file_cache, :sheet_variable_id, :user_id, :variable_id, :position, :remove_response_file

  # Concerns
  include Valuable

  # Model Validation
  validates_presence_of :sheet_variable_id, :position

  # Model Relationships
  belongs_to :sheet_variable, touch: true
  belongs_to :user

end
