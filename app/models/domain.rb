class Domain < ActiveRecord::Base
  serialize :options, Array

  before_save :check_option_validations

  # Concerns
  include Deletable

  # Named Scopes
  scope :search, lambda { |arg| where("LOWER(domains.name) LIKE ? or LOWER(domains.description) LIKE ? or LOWER(domains.options) LIKE ?", arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%')) }

  # Model Validation
  validates_presence_of :name, :display_name, :project_id, :user_id
  validates_format_of :name, with: /\A[a-z]\w*\Z/i
  validates :name, length: { maximum: 30 }
  validates_uniqueness_of :name, scope: [:deleted, :project_id]

  # Model Relationships
  belongs_to :user
  belongs_to :project
  has_many :variables, -> { where deleted: false }

  # Model Methods

  # Returns an array of the domains values
  def values
    @values ||= begin
      self.options.collect{|o| o[:value]}
    end
  end

  def variable_ids
    variable_ids = self.new_record? ? [] : self.variables.pluck(:id)
  end

  def sheet_variables
    SheetVariable.where(variable_id: self.variables.collect{|v| v.id})
  end

  def grids
    Grid.where(variable_id: self.variables.collect{|v| v.id})
  end

  # We want all validations to run so all errors will show up when submitting a form
  def check_option_validations
    result_a = check_for_colons
    result_b = check_value_uniqueness
    result_c = check_for_blank_values

    result_a and result_b and result_c
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
    if option_values.select{|opt| opt.to_s.strip.blank?}.size > 0
      self.errors.add(:option, "values can't be blank" )
      result = false
    end
    result
  end

  # All of these changes are rolled back if the domain is not saved successfully
  # Wrapped in single transaction
  def option_tokens=(tokens)
    unless self.new_record?
      original_options = self.options
      existing_options = tokens.reject{|hash| ['new', nil].include?(hash[:option_index]) }

      removable_options = original_options.reject.each_with_index{ |hash,index| existing_options.collect{|hash| hash[:option_index].to_i}.include?(index) }
      removable_values = removable_options.collect{ |hash| hash.symbolize_keys[:value] }

      changed_options = existing_options.reject{ |hash| original_options[hash[:option_index].to_i].symbolize_keys[:value].strip == hash[:value].strip }
      changed_values = changed_options.collect do |hash|
        old_value = original_options[hash[:option_index].to_i].symbolize_keys[:value].strip
        new_value = hash[:value].strip
        intermediate_value = old_value + ":" + new_value
        [old_value, intermediate_value, new_value]
      end

      sheet_transaction_ids = []

      # Reset any sheets that specified an option that has been removed
      sheet_transaction_ids = removable_values.collect{ |value| self.update_response_values(value, nil, sheet_transaction_ids) }.flatten.uniq

      # Update all existing sheets to intermediate value for values that already existed and have changed
      sheet_transaction_ids = changed_values.collect{ |old_value, intermediate_value, new_value| self.update_response_values(old_value, intermediate_value, sheet_transaction_ids) }.flatten.uniq

      # Update all existing sheets to new value
      sheet_transaction_ids = changed_values.collect{ |old_value, intermediate_value, new_value| self.update_response_values(intermediate_value, new_value, sheet_transaction_ids) }.flatten.uniq
    end

    self.options = []
    tokens.each do |option_hash|
      self.options << { name: option_hash[:name].strip,
                        value: option_hash[:value].strip,
                        description: option_hash[:description].to_s.strip,
                        missing_code: option_hash[:missing_code].to_s.strip
                      } unless option_hash[:name].strip.blank?
    end
  end

  def update_response_values(database_value, new_value, sheet_transaction_ids)
    sheet_transactions = SheetTransaction.where( id: sheet_transaction_ids )
    svs = self.sheet_variables.where(response: database_value)
    gds = self.grids.where(response: database_value)

    sheet_transaction_ids = (svs + gds).collect do |o|
      sheet_transaction = sheet_transactions.where( sheet_id: o.sheet_id ).first_or_create( transaction_type: 'domain_update', user_id: self.user.id, remote_ip: self.user.current_sign_in_ip )
      sheet_transaction.update_response_with_transaction(o, new_value, self.user)
      sheet_transaction.id
    end

    sheet_transaction_ids
  end

  # Returns true if all options are integers
  def all_numeric?
    self.options.select{|o| !(o[:value] =~ /^[-+]?[0-9]+$/)}.size == 0
  end

  def sas_value_domain
    "  value #{self.sas_domain_name}\n#{self.options.collect{|o| "    #{"'" unless self.all_numeric? }#{o[:value]}#{"'" unless self.all_numeric? }='#{o[:value]}: #{o[:name].gsub("'", "''")}'"}.join("\n")}\n  ;"
  end

  def sas_domain_name
    "#{ '$' unless self.all_numeric? }#{self.name}f"
  end

end
