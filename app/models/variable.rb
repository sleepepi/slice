class Variable < ActiveRecord::Base
  attr_accessible :description, :header, :name, :display_name, :options, :variable_type, :option_tokens, :minimum, :maximum, :project_id

  TYPE = ['dropdown', 'checkbox', 'radio', 'string', 'text', 'integer', 'numeric', 'date', 'file'].collect{|i| [i,i]}

  serialize :options, Array

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_user, lambda { |*args| { conditions: ['variables.user_id IN (?)', args.first] } }
  scope :with_user_or_global, lambda { |*args| { conditions: ['variables.user_id IN (?) or variables.project_id IS NULL', args.first] } }
  scope :search, lambda { |*args| { conditions: [ 'LOWER(name) LIKE ? or LOWER(description) LIKE ? or LOWER(display_name) LIKE ?', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }

  # Model Validation
  validates_presence_of :name, :display_name, :variable_type
  validates_format_of :name, with: /\A[a-z]\w*\Z/i
  validates_uniqueness_of :name, scope: [:deleted, :project_id]

  # Model Relationships
  belongs_to :user
  belongs_to :project
  has_many :sheet_variables

  # Model Methods
  def destroy
    update_attribute :deleted, true
  end

  def name_with_project
    self.project ? "#{self.name} - #{self.project.name}" : "#{self.name} - Global"
  end

  def editable_by?(current_user)
    current_user.all_variables.pluck(:id).include?(self.id) or (current_user.librarian? and self.project_id.blank?)
  end

  def copyable_attributes
    self.attributes.reject{|key, val| ['id', 'user_id', 'project_id', 'deleted', 'created_at', 'updated_at'].include?(key.to_s)}
  end

  # Check that user has selected an editable project  OR
  #            user is a librarian and project_id is blank
  def saveable?(current_user, params_project_id)
    result = (current_user.all_projects.pluck(:id).include?(params_project_id.to_i) or (current_user.librarian? and params_project_id.blank?))
    self.errors.add(:project_id, "can't be blank" ) unless result
    result
  end

  def description_range
    ["#{ "Min: #{self.minimum}" if self.minimum}", "#{ "Max: #{self.maximum}" if self.maximum}", self.description].select{|i| not i.blank?}.join(', ')
  end


  def option_tokens=(tokens)
    original_options = self.options
    existing_options = tokens.reject{|key, hash| ['new', nil].include?(hash[:option_index]) }

    # Update all existing sheets to intermediate value for values that already existed and have changed
    existing_options.each_pair do |key, hash|
      old_value = original_options[hash[:option_index].to_i].symbolize_keys[:value]
      new_value = hash[:value]
      if old_value != new_value
        intermediate_value = old_value + ":" + new_value
        self.sheet_variables.where(response: old_value).update_all(response: intermediate_value)
      end
    end

    # Update all existing sheets to new value
    existing_options.each_pair do |key, hash|
      old_value = original_options[hash[:option_index].to_i].symbolize_keys[:value]
      new_value = hash[:value]
      if old_value != new_value
        intermediate_value = old_value + ":" + new_value
        self.sheet_variables.where(response: intermediate_value).update_all(response: new_value)
      end
    end

    self.options = []
    tokens.each_pair do |key, option_hash|
      self.options << { name: option_hash[:name],
                        value: option_hash[:value],
                        description: option_hash[:description]
                      } unless option_hash[:name].blank?
    end
  end

  def response_name(sheet)
    sheet_variable = (sheet ? sheet.sheet_variables.find_by_variable_id(self.id) : nil)
    response = (sheet_variable ? sheet_variable.response : nil)
    if ['dropdown', 'radio'].include?(self.variable_type)
      (self.options.select{|option| option[:value] == response}.first || {})[:name]
    elsif ['checkbox'].include?(self.variable_type)
      array = YAML::load(response) rescue []
      (self.options.select{|option| array.include?(option[:value])}).collect{|option| option[:name]} || []
    else
      response
    end
  end

end
