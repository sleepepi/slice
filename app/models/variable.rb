class Variable < ActiveRecord::Base
  attr_accessible :description, :header, :name, :display_name, :options, :variable_type, :option_tokens, :project_id, :hard_minimum, :hard_maximum, :date_hard_maximum, :date_hard_minimum, :soft_minimum, :soft_maximum, :date_soft_maximum, :date_soft_minimum, :calculation, :updater_id

  TYPE = ['dropdown', 'checkbox', 'radio', 'string', 'text', 'integer', 'numeric', 'date', 'time', 'file', 'calculated'].collect{|i| [i,i]}

  serialize :options, Array

  before_save :check_option_validations

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
  belongs_to :updater, class_name: 'User', foreign_key: 'updater_id'

  # Model Methods
  def destroy
    update_column :deleted, true
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
    self.attributes.reject{|key, val| ['id', 'user_id', 'deleted', 'created_at', 'updated_at'].include?(key.to_s)}
  end

  # We want all validations to run so all errors will show up when submitting a form
  def check_option_validations
    result_a = check_project_id
    result_b = check_for_colons
    result_c = check_value_uniqueness
    result_d = check_for_blank_values

    result_a and result_b and result_c and result_d
  end

  def check_project_id
    result = (self.updater.all_projects.pluck(:id).include?(self.project_id) or (self.updater.librarian? and self.project_id.blank?))
    self.errors.add(:project_id, "can't be blank" ) unless result
    result
  end

  def check_for_colons
    result = true
    option_values = self.options.collect{|option| option[:value]}
    if option_values.join('').count(':') > 0
      self.errors.add(:option, "values can't contain colons" )
      result = false
    end
    result
  end

  def check_value_uniqueness
    result = true
    option_values = self.options.collect{|option| option[:value]}
    if option_values.uniq.size < option_values.size
      self.errors.add(:option, "values must be unique" )
      result = false
    end
    result
  end

  def check_for_blank_values
    result = true
    option_values = self.options.collect{|option| option[:value]}
    if ['dropdown', 'checkbox', 'radio'].include?(self.variable_type) and option_values.select{|opt| opt.to_s.strip.blank?}.size > 0
      self.errors.add(:option, "values can't be blank" )
      result = false
    end
    result
  end

  def description_range
    [self.description, self.range_table].select{|i| not i.blank?}.join('<br /><br />')
  end

  def range_table
    if self.hard_minimum or self.hard_maximum or self.soft_minimum or self.soft_maximum
      "<table class='table table-bordered table-striped' style='margin-bottom:0px'>
        <thead><tr><th>Hard Min</th><th>Soft Min</th><th>Soft Max</th><th>Hard Max</th></tr></thead>
        <tbody><tr><td>#{self.hard_minimum}</td><td>#{self.soft_minimum}</td><td>#{self.soft_maximum}</td><td>#{self.hard_maximum}</td></tr></tbody>
      </table>"
    else
      ""
    end
  end

  # All of these changes are rolled back if the sheet is not saved successfully
  # Wrapped in single transaction
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

  def response_file(sheet)
    result = ''
    sheet_variable = (sheet ? sheet.sheet_variables.find_by_variable_id(self.id) : nil)
    result = sheet_variable.response_file if sheet_variable
    result
  end

  def response_file_url(sheet)
    result = ''
    sheet_variable = (sheet ? sheet.sheet_variables.find_by_variable_id(self.id) : nil)
    result = sheet_variable.response_file_url if sheet_variable
    result
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
    elsif ['integer', 'numeric'].include?(self.variable_type)
      hash = self.options_only_missing.select{|option| option[:value] == response}.first
      hash.blank? ? response : [hash[:value], hash[:name]].compact.join(': ')
    elsif ['file'].include?(self.variable_type)
      self.response_file(sheet).to_s.split('/').last
    else
      response
    end
  end

  def response_label(sheet)
    sheet_variable = (sheet ? sheet.sheet_variables.find_by_variable_id(self.id) : nil)
    response = (sheet_variable ? sheet_variable.response : nil)
    if ['dropdown', 'radio'].include?(self.variable_type)
      hash = (self.options.select{|option| option[:value] == response}.first || {})
      hash[:name]
    elsif ['checkbox'].include?(self.variable_type)
      array = YAML::load(response) rescue array = []
      self.options.select{|option| array.include?(option[:value])}.collect{|option| option[:name]}
    elsif ['integer', 'numeric'].include?(self.variable_type)
      hash = self.options_only_missing.select{|option| option[:value] == response}.first
      hash.blank? ? response : hash[:name]
    elsif ['file'].include?(self.variable_type)
      self.response_file(sheet).to_s.split('/').last
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
    elsif ['file'].include?(self.variable_type)
      self.response_file(sheet).to_s.split('/').last
    else
      response
    end
  end

end
