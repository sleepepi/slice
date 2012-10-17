class Grid < ActiveRecord::Base
  attr_accessible :response, :response_file, :response_file_cache, :sheet_variable_id, :user_id, :variable_id, :position, :remove_response_file

  audited associated_with: :sheet_variable

  belongs_to :sheet_variable, touch: true
  belongs_to :variable
  belongs_to :user

  validates_presence_of :sheet_variable_id, :variable_id, :position, :user_id

  mount_uploader :response_file, GenericUploader


  def response_raw
    case self.variable.variable_type when 'checkbox'
      array = YAML::load(self.response) rescue array = []
      self.variable.options.select{|option| array.include?(option[:value])}.collect{|option| option[:value]}.join(',')
    when 'file'
      self.response_file.to_s.split('/').last
    else
      self.response
    end
  end

  def response_label
    if self.variable.variable_type == 'checkbox'
      array = YAML::load(self.response) rescue array = []
      self.variable.options.select{|option| array.include?(option[:value])}.collect{|option| option[:name]}.join(',')
    elsif ['dropdown', 'radio'].include?(self.variable.variable_type)
      hash = (self.variable.options.select{|option| option[:value] == self.response}.first || {})
      [hash[:value], hash[:name]].compact.join(': ')
    elsif ['integer', 'numeric'].include?(self.variable.variable_type)
      hash = self.variable.options_only_missing.select{|option| option[:value] == self.response}.first
      hash.blank? ? self.response : hash[:name]
    elsif self.variable.variable_type == 'file'
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
