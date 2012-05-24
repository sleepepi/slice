class Variable < ActiveRecord::Base
  attr_accessible :description, :header, :name, :options, :response, :variable_type, :option_tokens, :sheet_id

  TYPE = ['dropdown', 'checkbox', 'radio', 'string', 'text', 'integer', 'numeric', 'date', 'file'].collect{|i| [i,i]}

  serialize :options, Array
  # attr_reader :option_tokens

  # Named Scopes
  scope :current, conditions: { deleted: false }

  # Model Validation
  validates_presence_of :name, :variable_type
  validates_uniqueness_of :name, scope: [:deleted, :project_id, :sheet_id]

  # Model Relationships
  belongs_to :user
  belongs_to :project
  # has_and_belongs_to_many :sheets, conditions: { deleted: false }

  # Model Methods
  def destroy
    update_attribute :deleted, true
  end

  def option_tokens=(tokens)
    self.options = []
    tokens.each_pair do |key, option_hash|
      self.options << { name: option_hash[:name],
                        value: option_hash[:value],
                        position: option_hash[:position],
                        description: option_hash[:description]
                      } unless option_hash[:name].blank?
    end
    self.options.sort!{ |a,b| a.symbolize_keys[:position].to_i <=> b.symbolize_keys[:position].to_i }
  end

  def response_name
    case self.variable_type when 'dropdown'
      (self.options.select{|option| option[:value] == self.response}.first || {})[:name]
    else
      self.response
    end
  end

end
