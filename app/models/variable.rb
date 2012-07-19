class Variable < ActiveRecord::Base
  attr_accessible :description, :header, :name, :display_name, :options, :variable_type, :option_tokens, :project_id, :hard_minimum, :hard_maximum, :date_hard_maximum, :date_hard_minimum, :soft_minimum, :soft_maximum, :date_soft_maximum, :date_soft_minimum, :calculation

  TYPE = ['dropdown', 'checkbox', 'radio', 'string', 'text', 'integer', 'numeric', 'date', 'file', 'calculated'].collect{|i| [i,i]}

  serialize :options, Array

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_user, lambda { |*args| { conditions: ['variables.user_id IN (?)', args.first] } }
  scope :with_project, lambda { |*args| { conditions: ['variables.project_id IN (?)', args.first] } }
  scope :with_variable_type, lambda { |*args| { conditions: ['variables.variable_type IN (?)', args.first] } }
  scope :with_project_or_global, lambda { |*args| { conditions: ['variables.project_id IN (?) or variables.project_id IS NULL', args.first] } }
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

  def designs
    @designs ||= begin
      Design.current.select{|d| d.variable_ids.include?(self.id)}.sort_by(&:name)
    end
  end

  def header_anchor
    "_"+self.header.to_s.gsub(/[^\w]/, '_').downcase
  end

  def name_with_project
    @name_with_project ||= begin
      self.project ? "#{self.name} - #{self.project.name}" : "#{self.name} - Global"
    end
  end

  def editable_by?(current_user)
    current_user.all_variables.pluck(:id).include?(self.id) or (current_user.librarian? and self.project_id.blank?)
  end

  def copyable_attributes
    self.attributes.reject{|key, val| ['id', 'user_id', 'project_id', 'deleted', 'created_at', 'updated_at'].include?(key.to_s)}
  end

  # Check that user has selected an editable project  OR
  #            user is a librarian and project_id is blank
  def saveable?(current_user, params)
    result = (current_user.all_projects.pluck(:id).include?(params[:project_id].to_i) or (current_user.librarian? and params[:project_id].blank?))
    self.errors.add(:project_id, "can't be blank" ) unless result
    result = (valid_option_tokens?(current_user, params) and result)
    result
  end

  def valid_option_tokens?(current_user, params)
    return true unless ['dropdown', 'checkbox', 'radio'].include?(params[:variable_type])
    result = true
    option_values = (params[:option_tokens] || {}).select{|key, hash| not hash.symbolize_keys[:name].strip.blank?}.collect{|key, hash| hash.symbolize_keys[:value]}
    if option_values.join('').count(':') > 0
      self.errors.add(:option, "values can't contain colons" )
      result = false
    end
    if option_values.uniq.size < option_values.size
      self.errors.add(:option, "values must be unique" )
      result = false
    end
    if option_values.select{|opt| opt.strip.blank?}.size > 0
      self.errors.add(:option, "values can't be blank" )
      result = false
    end
    result
  end

  def description_range
    ["#{ "Min: #{self.hard_minimum}" if self.hard_minimum}", "#{ "Max: #{self.hard_maximum}" if self.hard_maximum}", self.description].select{|i| not i.blank?}.join(', ')
  end

  def option_tokens=(tokens)
    unless self.new_record?
      original_options = self.options
      existing_options = tokens.reject{|key, hash| ['new', nil].include?(hash[:option_index]) }

      # Reset any sheets that specified an option that has been removed
      original_options.each_with_index do |hash, index|
        unless existing_options.collect{|key, hash| hash[:option_index].to_i}.include?(index)
          self.sheet_variables.where(response: hash.symbolize_keys[:value]).update_all(response: nil)
        end
      end

      # Update all existing sheets to intermediate value for values that already existed and have changed
      existing_options.each_pair do |key, hash|
        old_value = original_options[hash[:option_index].to_i].symbolize_keys[:value].strip
        new_value = hash[:value].strip
        if old_value != new_value
          intermediate_value = old_value + ":" + new_value
          self.sheet_variables.where(response: old_value).update_all(response: intermediate_value)
        end
      end

      # Update all existing sheets to new value
      existing_options.each_pair do |key, hash|
        old_value = original_options[hash[:option_index].to_i].symbolize_keys[:value].strip
        new_value = hash[:value].strip
        if old_value != new_value
          intermediate_value = old_value + ":" + new_value
          self.sheet_variables.where(response: intermediate_value).update_all(response: new_value)
        end
      end
    end

    self.options = []
    tokens.each_pair do |key, option_hash|
      self.options << { name: option_hash[:name].strip,
                        value: option_hash[:value].strip,
                        description: option_hash[:description].strip,
                        missing_code: option_hash[:missing_code].to_s.strip
                      } unless option_hash[:name].strip.blank?
    end
  end

  def missing_codes
    self.options.select{|opt| opt[:missing_code] == '1'}.collect{|opt| opt[:value]}
  end

  def missing_codes_with_description
    self.options.select{|opt| opt[:missing_code] == '1'}.collect{|opt| "#{opt[:value]} #{opt[:name]}"}
  end

  def options_without_missing
    self.options.select{|opt| opt[:missing_code] != '1'}
  end

  def options_only_missing
    self.options.select{|opt| opt[:missing_code] == '1'}
  end

  def grouped_by_missing
    [ ['', self.options_without_missing.collect{|opt| [[opt[:value],opt[:name]].compact.join(': '),opt[:value]]}],
      ['Missing', self.options_only_missing.collect{|opt| [[opt[:value],opt[:name]].compact.join(': '),opt[:value]]}]
    ]
  end

  def response_name(sheet)
    sheet_variable = (sheet ? sheet.sheet_variables.find_by_variable_id(self.id) : nil)
    response = (sheet_variable ? sheet_variable.response : nil)
    if ['dropdown', 'radio'].include?(self.variable_type)
      hash = (self.options.select{|option| option[:value] == response}.first || {})
      [hash[:value], hash[:name]].compact.join(': ')
    elsif ['checkbox'].include?(self.variable_type)
      array = YAML::load(response) rescue array = []
      self.options.select{|option| array.include?(option[:value])}.collect{|option| option[:value] + ": " + option[:name]}
    else
      response
    end
  end

  def response_raw(sheet)
    sheet_variable = (sheet ? sheet.sheet_variables.find_by_variable_id(self.id) : nil)
    response = (sheet_variable ? sheet_variable.response : nil)
    if ['dropdown', 'radio'].include?(self.variable_type)
      response
    elsif ['checkbox'].include?(self.variable_type)
      array = YAML::load(response) rescue array = []
      self.options.select{|option| array.include?(option[:value])}.collect{|option| option[:value]}.join(',')
    else
      response
    end
  end

end
