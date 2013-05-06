class Variable < ActiveRecord::Base
  # attr_accessible :description, :header, :name, :display_name, :variable_type, :project_id, :updater_id, :display_name_visibility, :prepend, :append,
  #                 # Integer and Numeric
  #                 :hard_minimum, :hard_maximum, :soft_minimum, :soft_maximum,
  #                 # Date
  #                 :date_hard_maximum, :date_hard_minimum, :date_soft_maximum, :date_soft_minimum,
  #                 # Date and Time
  #                 :show_current_button,
  #                 # Calculated
  #                 :calculation, :format,
  #                 # Integer and Numeric and Calculated
  #                 :units,
  #                 # Grid
  #                 :grid_tokens, :grid_variables, :multiple_rows, :default_row_number,
  #                 # Autocomplete
  #                 :autocomplete_values,
  #                 # Radio and Checkbox
  #                 :alignment,
  #                 # Scale
  #                 :scale_type, :domain_id

  TYPE = ['dropdown', 'checkbox', 'radio', 'string', 'text', 'integer', 'numeric', 'date', 'time', 'file', 'calculated', 'grid', 'scale'].sort.collect{|i| [i,i]}
  TYPE_IMPORTABLE = ['string', 'text', 'integer', 'numeric', 'date', 'time'].sort.collect{|i| [i,i]}
  TYPE_DOMAIN = ['dropdown', 'checkbox', 'radio', 'integer', 'numeric', 'scale']
  CONTROL_SIZE = ['mini', 'small', 'medium', 'large', 'xlarge', 'xxlarge'].collect{|i| [i,i]}
  DISPLAY_NAME_VISIBILITY = [['Visible', 'visible'], ['Invisible', 'invisible'], ['Gone', 'gone']]
  ALIGNMENT = [['Horizontal', 'horizontal'], ['Vertical', 'vertical']]
  SCALE_TYPE = ['checkbox', 'radio'].collect{|i| [i,i]}

  serialize :grid_variables, Array

  before_save :check_for_duplicate_variables, :check_for_valid_domain

  # Concerns
  include Deletable

  # Named Scopes
  scope :search, lambda { |arg| where('LOWER(name) LIKE ? or LOWER(description) LIKE ? or LOWER(display_name) LIKE ?', arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%') ) }
  scope :with_user, lambda { |arg| where(user_id: arg) }
  scope :with_project, lambda { |arg| where(project_id: arg) }
  scope :with_variable_type, lambda { |arg| where(variable_type: arg) }
  scope :without_variable_type, lambda { |arg| where('variables.variable_type NOT IN (?)', arg) }

  # Model Validation
  validates_presence_of :name, :display_name, :variable_type, :project_id
  validates_format_of :name, with: /\A[a-z]\w*\Z/i
  validates :name, length: { maximum: 32 }
  validates_uniqueness_of :name, scope: [:deleted, :project_id]

  # Model Relationships
  belongs_to :user
  belongs_to :project
  belongs_to :domain
  has_many :sheet_variables
  has_many :grids
  has_many :responses
  belongs_to :updater, class_name: 'User', foreign_key: 'updater_id'

  # Model Methods

  def header_without_tags
    self.header.to_s.gsub(/<(.*?)>/, '')
  end

  def shared_options
    self.domain ? self.domain.options : []
  end

  def shared_options_select_values(values)
    self.shared_options.select{|option| values.include?(option[:value])}
  end

  def autocomplete_array
    self.autocomplete_values.to_s.split(/[\n\r]/).collect{|i| i.strip}
  end

  # Designs isn't used, using inherited designs instead.
  # def designs
  #   @designs ||= begin
  #     Design.current.select{|d| d.variable_ids.include?(self.id)}.sort_by(&:name)
  #   end
  # end

  def inherited_designs
    @inherited_designs ||= begin
      variable_ids = Variable.current.where(project_id: self.project_id, variable_type: 'grid').select{|v| v.grid_variable_ids.include?(self.id)}.collect{|v| v.id} + [self.id]
      Design.current.where(project_id: self.project_id).select{|d| (d.variable_ids & variable_ids).size > 0}.sort_by(&:name)
    end
  end

  def editable_by?(current_user)
    current_user.all_variables.pluck(:id).include?(self.id)
  end

  def copyable_attributes
    self.attributes.reject{|key, val| ['id', 'user_id', 'deleted', 'created_at', 'updated_at', 'options'].include?(key.to_s)}
  end

  # Includes responses, grids, and sheet_variables
  def captured_values
    @captured_values ||= begin
      (sheet_variables.pluck(:response) + grids.pluck(:response) + responses.pluck(:value)).uniq.select{|r| not r.blank?}
    end
  end

  def check_for_valid_domain
    result = true
    d = self.domain ? self.domain : Domain.new
    if self.has_domain? and (captured_values | d.values).size > d.values.size and not ['integer', 'numeric'].include?(self.variable_type)
      self.errors.add(:domain_id, "must include all previously captured values")
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

  # For tooltip
  def display_name_range
    [self.display_name, self.range_tooltip].select{|i| not i.blank?}.join(' ')
  end

  def range_tooltip
    result = ""
    minimum = self.hard_minimum || self.soft_minimum
    maximum = self.hard_maximum || self.soft_maximum
    if not minimum.blank? and not maximum.blank?
      result = "[#{minimum}, #{maximum}]" + (self.units.blank? ? "" : " #{self.units}")
    elsif minimum.blank? and not maximum.blank?
      result = "<= #{maximum}" + (self.units.blank? ? "" : " #{self.units}")
    elsif maximum.blank? and not minimum.blank?
      result = ">= #{minimum}" + (self.units.blank? ? "" : " #{self.units}")
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

  def grid_tokens=(tokens)
    self.grid_variables = []
    tokens.each do |grid_hash|
      self.grid_variables << { variable_id: grid_hash[:variable_id].strip.to_i,
                               control_size: Variable::CONTROL_SIZE.flatten.uniq.include?(grid_hash[:control_size].to_s.strip) ? grid_hash[:control_size].to_s.strip : 'large'
                             } if grid_hash[:variable_id].strip.to_i > 0
    end
  end

  def grid_variable_ids
    self.grid_variables.collect{|gv| gv[:variable_id]}
  end

  def missing_codes
    self.shared_options.select{|opt| opt[:missing_code] == '1'}.collect{|opt| opt[:value]}
  end

  def first_scale_variable?(design)
    return true unless design and self.header.blank?

    previous_variable = design.variables[design.variable_ids.index(self.id) - 1] if design.variable_ids.index(self.id) > 0
    # While this could just compare the variable domains, comparing the shared options allows scales with different domains (that have the same options) to still stack nicely on a form
    if previous_variable and previous_variable.variable_type == 'scale' and previous_variable.shared_options == self.shared_options
      return false
    else
      return true
    end
  end

  def options_missing_at_end
    self.shared_options.sort{|a, b| a[:missing_code].to_i <=> b[:missing_code].to_i}
  end

  def options_without_missing
    self.shared_options.select{|opt| opt[:missing_code] != '1'}
  end

  def options_only_missing
    self.shared_options.select{|opt| opt[:missing_code] == '1'}
  end

  def grouped_by_missing
    [ ['', self.options_without_missing.collect{|opt| [[opt[:value],opt[:name]].compact.join(': '),opt[:value]]}], ['Missing', self.options_only_missing.collect{|opt| [[opt[:value],opt[:name]].compact.join(': '),opt[:value]]}] ]
  end

  def options_or_autocomplete(include_missing)
    if self.variable_type == 'string'
      NaturalSort::naturalsort(self.autocomplete_array.select{|val| not val.blank?}.collect{|val| { name: val, value: val }}) + NaturalSort::naturalsort(self.user_submitted_sheet_variables.collect{|sv| { name: sv.response, value: sv.response, info: 'User Submitted' }}.uniq{|a| a[:value].downcase })
    else
      (include_missing ? self.shared_options : self.options_without_missing)
    end
  end

  # Responses that are user submitted and not on autocomplete list
  def user_submitted_sheet_variables
    self.sheet_variables.select{|sv| not self.autocomplete_array.include?(sv.response.to_s.strip) and not sv.response.to_s.strip.blank?}
  end

  def formatted_calculation
    self.calculation.to_s.gsub(/\?|\:/, '<br/>&nbsp;\0<br/>').html_safe
  end

  def has_statistics?
    ['integer', 'numeric', 'calculated'].include?(self.variable_type)
  end

  def has_domain?
    ['dropdown', 'checkbox', 'radio', 'integer', 'numeric', 'scale'].include?(self.variable_type)
  end

  def report_strata(include_missing, max_strata = 0, hash, sheet_scope)
    @report_strata = if self.has_statistics? and hash[:axis] == 'col'
      [ { filters: [], name: 'N',      tooltip: 'N',      calculation: 'array_count'                            },
        { filters: [], name: 'Mean',   tooltip: 'Mean',   calculation: 'array_mean'                             },
        { filters: [], name: 'StdDev', tooltip: 'StdDev', calculation: 'array_standard_deviation', symbol: 'pm' },
        { filters: [], name: 'Median', tooltip: 'Median', calculation: 'array_median'                           },
        { filters: [], name: 'Min',    tooltip: 'Min',    calculation: 'array_min'                              },
        { filters: [], name: 'Max',    tooltip: 'Max',    calculation: 'array_max'                              }]
    elsif ['dropdown', 'radio', 'string'].include?(self.variable_type)
      unique_responses = sheet_scope.sheet_responses(self).uniq
      options_or_autocomplete(include_missing).select{|h| unique_responses.include?(h[:value])}.collect{ |h| h.merge({ filters: [{ variable_id: self.id, value: h[:value] }], tooltip: h[:name] }) }
    elsif self.variable_type == 'design'
      self.project.designs.order(:name).collect{|design| { filters: [{ variable_id: 'design', value: design.id.to_s }], name: design.name, tooltip: design.name, link: "projects/#{self.project_id}/designs/#{design.id}/report", value: design.id.to_s, calculation: 'array_count' } }
    elsif self.variable_type == 'site'
      self.project.sites.order(:name).collect{|site| { filters: [{ variable_id: 'site', value: site.id.to_s }], name: site.name, tooltip: site.name, value: site.id.to_s, calculation: 'array_count' } }
    elsif ['sheet_date', 'date'].include?(self.variable_type)
      date_buckets = self.generate_date_buckets(sheet_scope, hash[:by] || 'month')
      date_buckets.reverse! unless hash[:axis] == 'col'
      date_buckets.collect do |date_bucket|
        { filters: [{ variable_id: (self.id ? self.id : self.name), start_date: date_bucket[:start_date], end_date: date_bucket[:end_date] }], name: date_bucket[:name], tooltip: date_bucket[:tooltip], calculation: 'array_count', start_date: date_bucket[:start_date], end_date: date_bucket[:end_date] }
      end
    else # Create a Filter that shows if the variable is present.
      display_name = "#{"#{hash[:variable].display_name} " if hash[:axis] == 'col'}Collected"
      [ { filters: [{ variable_id: self.id, value: ':any' }], name: display_name, tooltip: display_name } ]
    end
    @report_strata << { filters: [{ variable_id: self.id, value: ':missing' }], name: '', tooltip: 'Unknown', value: nil } if include_missing and not ['site', 'sheet_date'].include?(self.variable_type)
    @report_strata.collect!{|s| s.merge({ calculator: self, variable_id: self.id ? self.id : self.name })}
    @report_strata[0..(max_strata - 1)]
  end

  def edge_date(sheet_scope, method)
    result = if self.variable_type == 'sheet_date'
      sheet_scope.pluck(:created_at).send(method).to_date rescue Date.today
    else
      Date.strptime(sheet_scope.sheet_responses(self).select{|response| not response.blank?}.send(method), "%Y-%m-%d") rescue Date.today
    end
  end

  def min_date(sheet_scope)
    edge_date(sheet_scope, :min)
  end

  def max_date(sheet_scope)
    edge_date(sheet_scope, :max)
  end

  def generate_date_buckets(sheet_scope, by)
    min = self.min_date(sheet_scope)
    max = self.max_date(sheet_scope)
    date_buckets = []
    case by when "week"
      current_cweek = min.cweek
      (min.year..max.year).each do |year|
        (current_cweek..Date.parse("#{year}-12-28").cweek).each do |cweek|
          start_date = Date.commercial(year,cweek) - 1.day
          end_date = Date.commercial(year,cweek) + 5.days
          date_buckets << { name: "Week #{cweek}", tooltip: "#{year} #{start_date.strftime("%m/%d")}-#{end_date.strftime("%m/%d")} Week #{cweek}", start_date: start_date, end_date: end_date }
          break if year == max.year and cweek == max.cweek
        end
        current_cweek = 1
      end
    when "month"
      current_month = min.month
      (min.year..max.year).each do |year|
        (current_month..12).each do |month|
          start_date = Date.parse("#{year}-#{month}-01")
          end_date = Date.parse("#{year}-#{month}-01").end_of_month
          date_buckets << { name: "#{Date::ABBR_MONTHNAMES[month]} #{year}", tooltip: "#{Date::MONTHNAMES[month]} #{year}", start_date: start_date, end_date: end_date }
          break if year == max.year and month == max.month
        end
        current_month = 1
      end
    when "year"
      (min.year..max.year).each do |year|
        start_date = Date.parse("#{year}-01-01")
        end_date = Date.parse("#{year}-12-31")
        date_buckets << { name: year.to_s, tooltip: year.to_s, start_date: start_date, end_date: end_date }
      end
    end
    date_buckets
  end

  def self.site(project_id)
    self.new( project_id: project_id, name: 'site', display_name: 'Site', variable_type: 'site' )
  end

  def self.sheet_date(project_id)
    self.new( project_id: project_id, name: 'sheet_date', display_name: 'Sheet Date', variable_type: 'sheet_date' )
  end

  def self.design(project_id)
    self.new( project_id: project_id, name: 'design', display_name: 'Design', variable_type: 'design' )
  end

  def sas_informat
    if ['string', 'file'].include?(self.response_format_type)
      '$500'
    elsif ['date'].include?(self.response_format_type)
      'yymmdd10'
    elsif ['dropdown', 'radio'].include?(self.response_format_type) and self.domain and not self.domain.all_numeric?
      '$500'
    elsif ['numeric', 'integer', 'dropdown', 'radio'].include?(self.response_format_type)
      'best32'
    else # elsif ['text'].include?(self.response_format_type)
      '$5000'
    end
  end

  def sas_format
    self.sas_informat
  end

  def response_format_type
    self.variable_type == 'scale' ? self.scale_type : self.variable_type
  end

end
