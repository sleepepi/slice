# frozen_string_literal: true

# Represents a finite set of options for a given variable
class Domain < ApplicationRecord
  serialize :options, Array

  before_save :check_for_colons, :check_value_uniqueness,
              :check_for_blank_values, :check_for_blank_names

  # Concerns
  include Searchable, Deletable

  # Model Validation
  validates :name, :display_name, :project_id, :user_id, presence: true
  validates :name, format: { with: /\A[a-z]\w*\Z/i },
                   length: { maximum: 30 },
                   uniqueness: { scope: [:deleted, :project_id] }

  # Model Relationships
  belongs_to :user
  belongs_to :project
  has_many :variables, -> { where deleted: false }
  has_many :sheet_variables, through: :variables
  has_many :grids, through: :variables

  # Model Methods

  def self.searchable_attributes
    %w(name description options)
  end

  # Returns an array of the domains values
  def values
    options.collect { |o| o[:value].to_s.strip }
  end

  def names
    options.collect { |o| o[:name].to_s.strip }
  end

  def options_by_site?
    options.count { |o| o[:site_id].present? } > 0
  end

  def check_for_colons
    return if values.join.count(':') == 0
    errors.add :option, "values can't contain colons"
    throw :abort
  end

  def check_value_uniqueness
    return unless values.uniq.size < values.size
    errors.add :option, 'values must be unique'
    throw :abort
  end

  def check_for_blank_values
    return unless values.count(&:blank?) > 0
    errors.add :option, "values can't be blank"
    throw :abort
  end

  def check_for_blank_names
    return unless names.count(&:blank?) > 0
    errors.add :option, "names can't be blank"
    throw :abort
  end

  # All of these changes are rolled back if the domain is not saved successfully
  # Wrapped in single transaction
  def option_tokens=(tokens)
    unless new_record?
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
    tokens.each do |token|
      next unless token[:name].strip.present? || (token[:value].strip.present? && token[:option_index] != 'new')
      self.options << {
        name: token[:name].strip,
        value: token[:value].strip,
        description: token[:description].to_s.strip,
        missing_code: token[:missing_code].to_s.strip,
        site_id: token[:site_id].to_s.strip
      }
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
    options.count { |o| !(o[:value] =~ /^[-+]?[0-9]+$/) } == 0
  end

  def sas_value_domain
    "  value #{self.sas_domain_name}\n#{self.options.collect{|o| "    #{"'" unless self.all_numeric? }#{o[:value]}#{"'" unless self.all_numeric? }='#{o[:value]}: #{o[:name].gsub("'", "''")}'"}.join("\n")}\n  ;"
  end

  def sas_domain_name
    "#{ '$' unless all_numeric? }#{name}f"
  end

  def self.clean_option_tokens(params)
    (params[:option_tokens] || []).each_with_index do |option, index|
      params[:option_tokens][index][:value] = (index + 1).to_s if option[:name].present? && option[:value].blank?
    end
    params
  end
end
