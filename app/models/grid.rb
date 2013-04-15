require 'audited'
require 'audited/adapters/active_record'
# require 'audited/auditor'
# require 'audited/adapters/active_record/audit'

class Grid < ActiveRecord::Base
  # attr_accessible :response, :response_file, :response_file_cache, :sheet_variable_id, :user_id, :variable_id, :position, :remove_response_file

  audited associated_with: :sheet_variable

  # Concerns
  include Valuable

  # Model Validation
  validates_presence_of :sheet_variable_id, :position, :user_id

  # Model Relationships
  belongs_to :sheet_variable, touch: true
  belongs_to :user


  def update_responses!(values, current_user)
    old_response_ids = self.responses.collect{|r| r.id} # Could use pluck, but pluck has issues with scopes and unsaved objects
    new_responses = []
    values.select{|v| not v.blank?}.each do |value|
      new_responses << Response.where(sheet_id: self.sheet_variable.sheet_id, grid_id: self.id, variable_id: self.variable_id, value: value).first_or_create( user_id: current_user.id )
    end
    self.responses = new_responses
    Response.where(id: old_response_ids, grid_id: nil).destroy_all
  end

end
