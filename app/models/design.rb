class Design < ActiveRecord::Base
  attr_accessible :description, :name, :options, :option_tokens, :project_id, :email_template, :updater_id

  serialize :options, Array

  before_save :check_option_validations

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_user, lambda { |*args| { conditions: ['designs.user_id IN (?)', args.first] } }
  scope :with_project, lambda { |*args| { conditions: ['designs.project_id IN (?)', args.first] } }
  scope :with_project_or_global, lambda { |*args| { conditions: ['designs.project_id IN (?) or designs.project_id IS NULL', args.first] } }
  scope :with_user_or_global, lambda { |*args| { conditions: ['designs.user_id IN (?) or designs.project_id IS NULL', args.first] } }
  scope :search, lambda { |*args| { conditions: [ 'LOWER(name) LIKE ? or LOWER(description) LIKE ?', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }

  # Model Validation
  validates_presence_of :name, :user_id
  validates_uniqueness_of :name, scope: [:deleted, :project_id]

  # Model Relationships
  belongs_to :user
  belongs_to :project
  has_many :sheets, conditions: { deleted: false }
  belongs_to :updater, class_name: 'User', foreign_key: 'updater_id'

  # Model Methods
  def destroy
    update_column :deleted, true
  end

  def name_with_project
    self.project ? "#{self.name} - #{self.project.name}" : "#{self.name} - Global"
  end

  def editable_by?(current_user)
    current_user.all_designs.pluck(:id).include?(self.id) or (current_user.librarian? and self.project_id.blank?)
  end

  def copyable_attributes
    self.attributes.reject{|key, val| ['id', 'user_id', 'project_id', 'deleted', 'created_at', 'updated_at'].include?(key.to_s)}
  end

  # # Check that user has selected an editable project  OR
  # #            user is a librarian and project_id is blank
  # def saveable?(current_user, params)
  #   result = (current_user.all_projects.pluck(:id).include?(params[:project_id].to_i) or (current_user.librarian? and params[:project_id].blank?))
  #   self.errors.add(:project_id, "can't be blank" ) unless result
  #   result = (valid_option_tokens?(current_user, params) and result)
  #   result
  # end

  # def valid_option_tokens?(current_user, params)
  #   result = true
  #   option_variable_ids = (params[:option_tokens] || {}).select{|key, hash| not hash.symbolize_keys[:variable_id].to_s.strip.blank?}.collect{|key, hash| hash.symbolize_keys[:variable_id]}
  #   if option_variable_ids.uniq.size < option_variable_ids.size
  #     self.errors.add(:variables, "can only be added once")
  #     result = false
  #   end
  #   section_names = (params[:option_tokens] || {}).select{|key, hash| not hash.symbolize_keys[:section_name].to_s.strip.blank?}.collect{|key, hash| hash.symbolize_keys[:section_name]}
  #   if section_names.uniq.size < section_names.size
  #     self.errors.add(:section_names, "must be unique")
  #     result = false
  #   end
  #   result
  # end

  # We want all validations to run so all errors will show up when submitting a form
  def check_option_validations
    result_a = check_project_id
    result_b = check_variable_ids
    result_c = check_section_names

    result_a and result_b and result_c
  end

  def check_project_id
    result = (self.updater.all_projects.pluck(:id).include?(self.project_id) or (self.updater.librarian? and self.project_id.blank?))
    self.errors.add(:project_id, "can't be blank" ) unless result
    result
  end

  def check_variable_ids
    result = true
    if self.variable_ids.uniq.size < self.variable_ids.size
      self.errors.add(:variables, "can only be added once")
      result = false
    end
    result
  end

  def check_section_names
    result = true
    if self.section_names.uniq.size < self.section_names.size
      self.errors.add(:section_names, "must be unique")
      result = false
    end
    result
  end

  def option_tokens=(tokens)
    self.options = []
    tokens.each_pair do |key, option_hash|
      if option_hash[:section_name].blank?
        self.options << {
                          variable_id: option_hash[:variable_id],
                          condition_variable_id: option_hash[:condition_variable_id],
                          condition_value: option_hash[:condition_value].to_s.strip,
                          branching_logic: option_hash[:branching_logic].to_s.strip
                        } unless option_hash[:variable_id].blank?
      else
        self.options << {
                          section_name: option_hash[:section_name].strip,
                          section_id: "_" + option_hash[:section_name].strip.gsub(/[^\w]/,'_').downcase,
                          section_description: option_hash[:section_description].strip,
                          branching_logic: option_hash[:branching_logic].to_s.strip
                        }
      end
    end
  end

  # [{"location": "#varvar_145", "values": []}, {"location": "#varvar_145", "values": []}]
  def values_hash(variable)
    [{ location: self.condition_parent(variable), values: self.condition_value(variable) }].to_json
  end

  def branching_logic_section(section_id)
    self.options.select{|item| item[:section_id].to_s == section_id.to_s }.collect{|item| item[:branching_logic].to_s.gsub(/([a-zA-Z]+[\w]*)/){|m| variable_replacement($1)}}.join(' ').to_json
  end

  def branching_logic(variable)
    self.options.select{|item| item[:variable_id].to_i == variable.id }.collect{|item| item[:branching_logic].to_s.gsub(/([a-zA-Z]+[\w]*)/){|m| variable_replacement($1)}}.join(' ').to_json
  end

  def variable_replacement(variable_name)
    variable = self.pure_variables.find_by_name(variable_name)
    if variable and ['radio'].include?(variable.variable_type)
      "$(\"[name='variables[#{variable.id}]']:checked\").val()"
    elsif variable and ['checkbox'].include?(variable.variable_type)
      "$.map($(\"[name='variables[#{variable.id}][]']:checked\"),function(el){return $(el).val();})"
    elsif variable
      "$(\"#variables_#{variable.id}\").val()"
    else
      variable_name
    end
  end

  def condition_parent(variable)
    self.options.select{|item| item[:variable_id].to_i == variable.id }.collect{|item| "#varvar_#{item[:condition_variable_id]}"}.join(',')
  end

  def condition_value(variable)
    self.options.select{|item| item[:variable_id].to_i == variable.id }.collect{ |item| item[:condition_value].to_s.split(",") }.flatten
  end

  def variable_ids
    @variable_ids ||= begin
      self.options.select{|option| not option[:variable_id].blank?}.collect{|option| option[:variable_id].to_i}
    end
  end

  def sections
    self.options.select{|option| not option[:section_name].blank?}
  end

  def section_names
    @section_names ||= begin
      self.sections.collect{|option| option[:section_name]}
    end
  end

  # ActiveRecord...
  def pure_variables
    Variable.current.where(id: variable_ids)
  end

  # Array...
  def variables
    pure_variables.sort!{ |a, b| variable_ids.index(a.id) <=> variable_ids.index(b.id) }
  end

  # sections = ["section_0","section_2","section_1"]
  def reorder_sections(section_positions, current_user)
    new_sections = section_positions.collect{|a| a.gsub('section_', '').to_i}
    return if new_sections.size == 0 or new_sections.sort != (0..self.section_names.size - 1).to_a
    original_sections = {}

    current_section = nil
    range_start = 0
    section_count = 0
    self.options.each_with_index do |option, index|
      if option[:section_name].blank?
        original_sections[current_section] = [range_start, index]
      else
        current_section = section_count
        section_count += 1
        range_start = index
        original_sections[current_section] = [range_start, index]
      end
    end

    rows = original_sections[nil].blank? ? [] : (original_sections[nil][0]..original_sections[nil][1]).to_a

    new_sections.each do |position|
      rows = rows + (original_sections[position][0]..original_sections[position][1]).to_a
    end

    self.reorder(rows.collect{|i| "option_#{i}"}, current_user)
  end

  def reorder(rows, current_user)
    new_rows = rows.collect{|a| a.gsub('option_', '').to_i}
    return if new_rows.size == 0 or new_rows.sort != (0..self.options.size - 1).to_a

    original_options = self.options
    new_options = []

    new_rows.each_with_index do |row, new_location|
      old_location = row
      Rails.logger.debug "Moving: #{old_location} to #{new_location}"
      new_options << original_options[old_location]
    end

    # Only change if the options match up
    if new_options.size == original_options.size
      self.update_attributes updater_id: current_user.id, options: new_options
      self.reload
    end
  end

end
