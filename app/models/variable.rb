class Variable < ActiveRecord::Base
  attr_accessible :description, :header, :name, :options, :response, :variable_type, :option_tokens, :sheet_id

  TYPE = ['dropdown', 'checkbox', 'radio', 'string', 'text', 'integer', 'numeric', 'date', 'file'].collect{|i| [i,i]}

  serialize :options, Array

  # Named Scopes
  scope :current, conditions: { deleted: false }

  # Model Validation
  validates_presence_of :name, :variable_type
  validates_uniqueness_of :name, scope: [:deleted, :project_id, :sheet_id]

  # Model Relationships
  belongs_to :user
  belongs_to :project
  belongs_to :sheet

  # Model Methods
  def destroy
    update_attribute :deleted, true
  end

  def option_tokens=(tokens)
    self.options = []
    tokens.each_pair do |key, option_hash|
      self.options << { name: option_hash[:name],
                        value: option_hash[:value],
                        description: option_hash[:description]
                      } unless option_hash[:name].blank?
    end
  end

  def response_name
    if ['dropdown', 'radio'].include?(self.variable_type)
      (self.options.select{|option| option[:value] == self.response}.first || {})[:name]
    elsif ['checkbox'].include?(self.variable_type)
      array = YAML::load(self.response) rescue []
      (self.options.select{|option| array.include?(option[:value])}).collect{|option| option[:name]} || []
    else
      self.response
    end
  end

end
