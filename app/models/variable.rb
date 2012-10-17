class Variable < ActiveRecord::Base
  attr_accessible :description, :header, :name, :display_name, :options, :variable_type, :option_tokens, :project_id, :updater_id, :display_name_visibility, :prepend, :append,
                  # Integer and Numeric
                  :hard_minimum, :hard_maximum, :soft_minimum, :soft_maximum,
                  # Date
                  :date_hard_maximum, :date_hard_minimum, :date_soft_maximum, :date_soft_minimum,
                  # Date and Time
                  :show_current_button,
                  # Calculated
                  :calculation, :format,
                  # Integer and Numeric and Calculated
                  :units,
                  # Grid
                  :grid_tokens, :grid_variables, :multiple_rows,
                  # Autocomplete
                  :autocomplete_values,
                  # Radio and Checkbox
                  :alignment

  TYPE = ['dropdown', 'checkbox', 'radio', 'string', 'text', 'integer', 'numeric', 'date', 'time', 'file', 'calculated', 'grid'].sort.collect{|i| [i,i]}
  CONTROL_SIZE = ['mini', 'small', 'medium', 'large', 'xlarge', 'xxlarge'].collect{|i| [i,i]}
  DISPLAY_NAME_VISIBILITY = [['Visible', 'visible'], ['Invisible', 'invisible'], ['Gone', 'gone']]
  ALIGNMENT = [['Horizontal', 'horizontal'], ['Vertical', 'vertical']]

  serialize :options, Array
  serialize :grid_variables, Array

  before_save :check_option_validations

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_user, lambda { |*args| { conditions: ['variables.user_id IN (?)', args.first] } }
  scope :with_project, lambda { |*args| { conditions: ['variables.project_id IN (?)', args.first] } }
  scope :with_variable_type, lambda { |*args| { conditions: ['variables.variable_type IN (?)', args.first] } }
  scope :without_variable_type, lambda { |*args| { conditions: ['variables.variable_type NOT IN (?)', args.first] } }
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
  has_many :grids
  belongs_to :updater, class_name: 'User', foreign_key: 'updater_id'

  def autocomplete_array
    self.autocomplete_values.to_s.split(/[\n\r]/).collect{|i| i.strip}
  end

  # Model Methods
  def destroy
    update_column :deleted, true
  end

  def designs
    @designs ||= begin
      Design.current.select{|d| d.variable_ids.include?(self.id)}.sort_by(&:name)
    end
  end

  # No longer required
  # def header_anchor
  #   "_"+self.header.to_s.gsub(/[^\w]/, '_').downcase
  # end

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
    result_e = check_for_duplicate_variables

    result_a and result_b and result_c and result_d and result_e
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

  def check_for_duplicate_variables
    result = true
    variable_ids = self.grid_variables.collect{|grid_variable| grid_variable[:variable_id]}
    if variable_ids.uniq.size < variable_ids.size
      self.errors.add(:grid, "variables must be unique" )
      result = false
    end
    result
  end

  def description_range
    [self.description, self.range_table].select{|i| not i.blank?}.join('<br /><br />')
  end

  def range_table
    result = ""
    if self.hard_minimum or self.hard_maximum or self.soft_minimum or self.soft_maximum
      result += "<table class='table table-bordered table-striped' style='margin-bottom:0px'>"
      result += "<thead><tr><th>Hard Min</th><th>Soft Min</th><th>Soft Max</th><th>Hard Max</th></tr></thead>"
      result += "<tbody><tr><td>#{self.hard_minimum}</td><td>#{self.soft_minimum}</td><td>#{self.soft_maximum}</td><td>#{self.hard_maximum}</td></tr></tbody>"
      result += "</table>"
    end
    result
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
          self.grids.where(response: hash.symbolize_keys[:value]).update_all(response: nil)
        end
      end

      # Update all existing sheets to intermediate value for values that already existed and have changed
      existing_options.each_pair do |key, hash|
        old_value = original_options[hash[:option_index].to_i].symbolize_keys[:value].strip
        new_value = hash[:value].strip
        if old_value != new_value
          intermediate_value = old_value + ":" + new_value
          self.sheet_variables.where(response: old_value).update_all(response: intermediate_value)
          self.grids.where(response: old_value).update_all(response: intermediate_value)
        end
      end

      # Update all existing sheets to new value
      existing_options.each_pair do |key, hash|
        old_value = original_options[hash[:option_index].to_i].symbolize_keys[:value].strip
        new_value = hash[:value].strip
        if old_value != new_value
          intermediate_value = old_value + ":" + new_value
          self.sheet_variables.where(response: intermediate_value).update_all(response: new_value)
          self.grids.where(response: intermediate_value).update_all(response: new_value)
        end
      end
    end

    self.options = []
    tokens.each_pair do |key, option_hash|
      self.options << { name: option_hash[:name].strip,
                        value: option_hash[:value].strip,
                        description: option_hash[:description].strip,
                        missing_code: option_hash[:missing_code].to_s.strip,
                        color: option_hash[:color].to_s.strip.blank? ? '#ffffff' : option_hash[:color]
                      } unless option_hash[:name].strip.blank?
    end
  end

  def grid_tokens=(tokens)
    self.grid_variables = []
    tokens.each_pair do |key, grid_hash|
      self.grid_variables << { variable_id: grid_hash[:variable_id].strip.to_i,
                               control_size: Variable::CONTROL_SIZE.flatten.uniq.include?(grid_hash[:control_size].to_s.strip) ? grid_hash[:control_size].to_s.strip : 'large'
                             } if grid_hash[:variable_id].strip.to_i > 0
    end
  end

  def missing_codes
    self.options.select{|opt| opt[:missing_code] == '1'}.collect{|opt| opt[:value]}
  end

  # Currently unused
  # def missing_codes_with_description
  #   self.options.select{|opt| opt[:missing_code] == '1'}.collect{|opt| "#{opt[:value]} #{opt[:name]}"}
  # end

  def options_without_missing
    self.options.select{|opt| opt[:missing_code] != '1'}
  end

  def options_only_missing
    self.options.select{|opt| opt[:missing_code] == '1'}
  end

  def grouped_by_missing
    [ ['', self.options_without_missing.collect{|opt| [[opt[:value],opt[:name]].compact.join(': '),opt[:value]]}], ['Missing', self.options_only_missing.collect{|opt| [[opt[:value],opt[:name]].compact.join(': '),opt[:value]]}] ]
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

  def response_name_helper(response, sheet=nil)
    sheet_variable = (sheet ? sheet.sheet_variables.find_by_variable_id(self.id) : nil)

    if ['dropdown', 'radio'].include?(self.variable_type)
      hash = (self.options.select{|option| option[:value] == response}.first || {})
      [hash[:value], hash[:name]].compact.join(': ')
    elsif ['checkbox'].include?(self.variable_type)
      response = YAML::load(response) rescue response = [] unless response.kind_of?(Array)
      self.options.select{|option| response.include?(option[:value])}.collect{|option| option[:value] + ": " + option[:name]}
    elsif ['grid'].include?(self.variable_type) and sheet_variable
      grid_labeled = []
      (0..sheet_variable.grids.pluck(:position).max.to_i).each do |position|
        self.grid_variables.each do |grid_variable|
          grid = sheet_variable.grids.find_by_variable_id_and_position(grid_variable[:variable_id], position)
          grid_labeled[position] ||= {}
          grid_labeled[position][grid.variable.name] = grid.response_label if grid
        end
      end
      grid_labeled.to_json

    elsif ['integer', 'numeric'].include?(self.variable_type)
      hash = self.options_only_missing.select{|option| option[:value] == response}.first
      hash.blank? ? response : [hash[:value], hash[:name]].compact.join(': ')
    elsif ['file'].include?(self.variable_type)
      self.response_file(sheet).size > 0 ? self.response_file(sheet).to_s.split('/').last : ''
    else
      response
    end
  end

  def response_name(sheet)
    sheet_variable = (sheet ? sheet.sheet_variables.find_by_variable_id(self.id) : nil)
    response = (sheet_variable ? sheet_variable.response : nil)
    response_name_helper(response, sheet)
  end

  def response_label(sheet)
    sheet_variable = (sheet ? sheet.sheet_variables.find_by_variable_id(self.id) : nil)
    response = (sheet_variable ? sheet_variable.response : nil)
    if ['dropdown', 'radio'].include?(self.variable_type)
      hash = (self.options.select{|option| option[:value] == response}.first || {})
      hash[:name]
    elsif ['checkbox'].include?(self.variable_type)
      array = YAML::load(response) rescue array = []
      self.options.select{|option| array.include?(option[:value])}.collect{|option| option[:name]}.join(',')
    elsif ['grid'].include?(self.variable_type) and sheet_variable
      grid_labeled = []
      (0..sheet_variable.grids.pluck(:position).max.to_i).each do |position|
        self.grid_variables.each do |grid_variable|
          grid = sheet_variable.grids.find_by_variable_id_and_position(grid_variable[:variable_id], position)
          grid_labeled[position] ||= {}
          grid_labeled[position][grid.variable.name] = grid.response_label if grid
        end
      end
      grid_labeled.to_json
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
    elsif ['grid'].include?(self.variable_type) and sheet_variable
      grid_raw = []
      (0..sheet_variable.grids.pluck(:position).max.to_i).each do |position|
        self.grid_variables.each do |grid_variable|
          grid = sheet_variable.grids.find_by_variable_id_and_position(grid_variable[:variable_id], position)
          grid_raw[position] ||= {}
          grid_raw[position][grid.variable.name] = grid.response_raw if grid
        end
      end
      grid_raw.to_json
    else
      response
    end
  end

  def response_color(sheet)
    sheet_variable = (sheet ? sheet.sheet_variables.find_by_variable_id(self.id) : nil)
    response = (sheet_variable ? sheet_variable.response : nil)
    color = self.options.select{|option| response == option[:value]}.collect{|option| option[:color]}.first
    color.blank? ? '#ffffff' : color
  end

  def options_or_autocomplete(include_missing)
    if self.variable_type == 'string'
      self.autocomplete_array.select{|val| not val.blank?}.collect{|val| { name: val, value: val }} +
      self.user_submitted_sheet_variables.collect{|sv| { name: sv.response, value: sv.response, info: 'User Submitted' }}.uniq{|a| a[:value].downcase }
    else
      (include_missing ? self.options : self.options_without_missing)
    end
  end

  # Responses that are user submitted and not on autocomplete list
  def user_submitted_sheet_variables
    self.sheet_variables.select{|sv| not self.autocomplete_array.include?(sv.response.to_s.strip) and not sv.response.to_s.strip.blank?}
  end

  # def response_description(value)
  #   option = self.options.select{|opt| opt[:value].to_s == value.to_s}.first
  #   option ? option[:description] : ''
  # end

end
