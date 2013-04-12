require 'audited'
require 'audited/adapters/active_record'
# require 'audited/auditor'
# require 'audited/adapters/active_record/audit'

class Grid < ActiveRecord::Base
  # attr_accessible :response, :response_file, :response_file_cache, :sheet_variable_id, :user_id, :variable_id, :position, :remove_response_file

  audited associated_with: :sheet_variable

  # Named Scopes
  scope :with_variable_type, lambda { |*args| { conditions: ['grids.variable_id in (SELECT variables.id from variables where variables.variable_type IN (?))', args.first] } }

  # Model Validation
  validates_presence_of :sheet_variable_id, :variable_id, :position, :user_id

  # Model Relationships
  belongs_to :sheet_variable, touch: true
  belongs_to :variable
  belongs_to :user
  has_many :responses

  mount_uploader :response_file, GenericUploader


  def update_responses!(values, current_user)
    old_response_ids = self.responses.collect{|r| r.id} # Could use pluck, but pluck has issues with scopes and unsaved objects
    new_responses = []
    values.select{|v| not v.blank?}.each do |value|
      r = Response.find_or_create_by_sheet_id_and_grid_id_and_variable_id_and_value(self.sheet_variable.sheet_id, self.id, self.variable_id, value, { user_id: current_user.id })
      new_responses << r
    end
    self.responses = new_responses
    Response.where(id: old_response_ids, grid_id: nil).destroy_all
  end

  def response_raw
    case self.variable.response_format_type
    when 'checkbox'
      self.variable.shared_options_select_values(self.responses.pluck(:value)).collect{|option| option[:value]}.join(',')
    when 'file'
      self.response_file.to_s.split('/').last
    when 'numeric', 'calculated'
      begin Float(self.response) end rescue self.response
    when 'integer', 'dropdown', 'radio'
      begin Integer(self.response) end rescue self.response
    else
      self.response
    end
  end

  def response_label
    case self.variable.response_format_type
    when 'checkbox'
      self.variable.shared_options_select_values(self.responses.pluck(:value)).collect{|option| option[:name]}.join(',')
    when 'dropdown', 'radio'
      hash = (self.variable.shared_options_select_values([self.response]).first || {})
      [hash[:value], hash[:name]].compact.join(': ')
    when 'integer', 'numeric'
      hash = self.variable.options_only_missing_select_values([self.response]).first
      hash.blank? ? self.response : hash[:name]
    when 'file'
      self.response_file.to_s.split('/').last
    else
      self.response
    end
  end

  def response_with_add_on
    prepend_string = ''
    append_string = ''

    prepend_string = self.variable.prepend + " " if not self.response.blank? and not self.variable.prepend.blank?
    append_string =  " " + self.variable.append if not self.response.blank? and not self.variable.append.blank?
    prepend_string + self.response + append_string
  end

end
