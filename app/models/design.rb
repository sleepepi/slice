class Design < ActiveRecord::Base
  attr_accessible :description, :name, :options, :option_tokens

  serialize :options, Array

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :search, lambda { |*args| { conditions: [ 'LOWER(name) LIKE ? or LOWER(description) LIKE ?', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }

  # Model Validation
  validates_presence_of :name, :user_id
  validates_uniqueness_of :name, scope: [:deleted, :project_id]

  # Model Relationships
  belongs_to :user
  belongs_to :project
  has_many :sheets, conditions: { deleted: false }

  # Model Methods
  def destroy
    update_attribute :deleted, true
  end

  def option_tokens=(tokens)
    self.options = []
    tokens.each_pair do |key, option_hash|
      self.options << { variable_id: option_hash[:variable_id] } unless option_hash[:variable_id].blank?
    end
  end

  def variable_ids
    @variable_ids ||= begin
      self.options.collect{|option| option[:variable_id].to_i}
    end
  end

  def variables
    Variable.current.where(id: variable_ids).sort!{ |a, b| variable_ids.index(a.id) <=> variable_ids.index(b.id) }
  end
end
