module Valuable
  extend ActiveSupport::Concern

  included do
    # Named Scopes
    scope :with_variable_type, lambda { |arg| where( "#{self.table_name}.variable_id in (SELECT variables.id from variables where variables.variable_type IN (?))", arg ) }

    # Model Validation
    validates_presence_of :variable_id

    # Model Relationships
    belongs_to :variable
    has_many :responses

    mount_uploader :response_file, GenericUploader
  end

  def get_response(raw_format = :raw)
    case self.variable.response_format_type
    when 'grid'
      self.respond_to?('grids') ? self.grid_responses(raw_format) : self.response
    when 'checkbox'
      self.checkbox_responses(raw_format)
    when 'dropdown', 'radio'
      self.dropdown_or_radio_response(raw_format)
    when 'integer'
      self.integer_response(raw_format)
    when 'numeric'
      self.numeric_response(raw_format)
    when 'calculated'
      self.calculated_response(raw_format)
    when 'file'
      self.file_response
    else
      self.response
    end
  end

  def grid_responses(raw_format = :raw)
    grid_responses = []
    (0..self.grids.pluck(:position).max.to_i).each do |position|
      self.variable.grid_variables.each do |grid_variable|
        grid = self.grids.find_by_variable_id_and_position(grid_variable[:variable_id], position)
        grid_responses[position] ||= {}
        grid_responses[position][grid.variable.name] = grid.get_response(raw_format) if grid
      end
    end
    grid_responses.to_json
  end

  def checkbox_responses(raw_format = :raw)
    self.variable.shared_options_select_values(self.responses.pluck(:value)).collect{|option| option[(raw_format == :raw ? :value : :name)]}.join(',')
  end

  def file_response
    self.variable.response_file(self.sheet).to_s.split('/').last
  end

  def dropdown_or_radio_response(raw_format = :raw)
    if raw_format == :raw
      begin Integer(self.response) end rescue self.response
    else
      hash_name
    end
  end

  def integer_response(raw_format = :raw)
    if raw_format == :raw
      begin Integer(self.response) end rescue self.response
    else
      hash_name_or_response
    end
  end

  def numeric_response(raw_format = :raw)
    if raw_format == :raw
      begin Float(self.response) end rescue self.response
    else
      hash_name_or_response
    end
  end

  def calculated_response(raw_format = :raw)
    if raw_format == :raw
      begin Float(self.response) end rescue self.response
    else
      self.response
    end
  end

  def hash_name_or_response
    hash_name.blank? ? self.response : hash_name
  end

  def hash_name
    hash = (self.variable.shared_options_select_values([self.response]).first || {})
    hash[:name]
  end

end
