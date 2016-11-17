# frozen_string_literal: true

# Represents a finite set of options for a given variable
class Domain < ApplicationRecord
  serialize :deprecated_options, Array

  before_save :check_for_colons, :check_value_uniqueness,
              :check_for_blank_values, :check_for_blank_names

  # Concerns
  include Searchable, Deletable

  attr_accessor :option_tokens

  # Model Validation
  validates :name, :display_name, :project_id, :user_id, presence: true
  validates :name, format: { with: /\A[a-z]\w*\Z/i },
                   length: { maximum: 30 },
                   uniqueness: { scope: [:deleted, :project_id] }

  # Model Relationships
  belongs_to :user
  belongs_to :project
  has_many :domain_options, -> { order('position nulls last', :id) }
  has_many :variables, -> { current }
  has_many :sheet_variables, through: :variables
  has_many :grids, through: :variables
  has_many :responses, through: :variables

  # Model Methods

  def self.searchable_attributes
    %w(name description)
  end

  # Returns an array of the domains values
  # TODO: Check if the places that reference this could be optimized
  def values
    domain_options.pluck(:value)
    # options.collect { |o| o[:value].to_s.strip }
  end

  # TODO: Check if the places that reference this could be optimized
  def names
    domain_options.pluck(:name)
    # options.collect { |o| o[:name].to_s.strip }
  end

  def missing_codes?
    domain_options.where(missing_code: true).count > 0
  end

  def descriptions?
    domain_options.where.not(description: [nil, '']).count > 0
  end

  def sites?
    domain_options.where.not(site_id: nil).count > 0
  end

  def archived_options?
    domain_options.where(archived: true).count > 0
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

  # # All of these changes are rolled back if the domain is not saved successfully
  # # Wrapped in single transaction
  # def option_tokens=(tokens)
  #   unless new_record?
  #     original_options = self.options
  #     existing_options = tokens.reject{|hash| ['new', nil].include?(hash[:option_index]) }

  #     removable_options = original_options.reject.each_with_index{ |hash,index| existing_options.collect{|hash| hash[:option_index].to_i}.include?(index) }
  #     removable_values = removable_options.collect{ |hash| hash.symbolize_keys[:value] }

  #     changed_options = existing_options.reject{ |hash| original_options[hash[:option_index].to_i].symbolize_keys[:value].strip == hash[:value].strip }
  #     changed_values = changed_options.collect do |hash|
  #       old_value = original_options[hash[:option_index].to_i].symbolize_keys[:value].strip
  #       new_value = hash[:value].strip
  #       intermediate_value = old_value + ":" + new_value
  #       [old_value, intermediate_value, new_value]
  #     end

  #     sheet_transaction_ids = []

  #     # Reset any sheets that specified an option that has been removed
  #     sheet_transaction_ids = removable_values.collect{ |value| update_response_values(value, nil, sheet_transaction_ids) }.flatten.uniq

  #     # Update all existing sheets to intermediate value for values that already existed and have changed
  #     sheet_transaction_ids = changed_values.collect{ |old_value, intermediate_value, new_value| update_response_values(old_value, intermediate_value, sheet_transaction_ids) }.flatten.uniq

  #     # Update all existing sheets to new value
  #     sheet_transaction_ids = changed_values.collect{ |old_value, intermediate_value, new_value| update_response_values(intermediate_value, new_value, sheet_transaction_ids) }.flatten.uniq
  #   end

  #   self.options = []
  #   tokens.each do |token|
  #     next unless token[:name].strip.present? || (token[:value].strip.present? && token[:option_index] != 'new')
  #     self.options << {
  #       name: token[:name].strip,
  #       value: token[:value].strip,
  #       description: token[:description].to_s.strip,
  #       missing_code: token[:missing_code].to_s.strip,
  #       site_id: token[:site_id].to_s.strip
  #     }
  #   end
  # end

  # TODO: Check if this updates checkbox responses correctly.
  def update_response_values(database_value, new_value, sheet_transaction_ids)
    sheet_transactions = SheetTransaction.where( id: sheet_transaction_ids )
    svs = sheet_variables.where(response: database_value)
    gds = grids.where(response: database_value)
    sheet_transaction_ids = (svs + gds).collect do |valuable|
      sheet_transaction = sheet_transactions.where(sheet_id: valuable.sheet_id).first_or_create(transaction_type: 'domain_update', user_id: user.id, remote_ip: user.current_sign_in_ip)
      sheet_transaction.update_response_with_transaction(valuable, new_value, user)
      sheet_transaction.id
    end
    sheet_transaction_ids
  end

  # Returns true if all options are integers
  # TODO: Check where this is referenced for optimization
  # TODO: Currently doesn't allow decimals.
  def all_numeric?
    @all_numeric ||= begin
      domain_options.count { |o| !(o.value =~ /^[-+]?[0-9]+$/) } == 0
    end
    # options.count { |o| !(o[:value] =~ /^[-+]?[0-9]+$/) } == 0
  end

  def sas_value_domain
    "  value #{sas_domain_name}\n#{domain_options.collect { |o| "    #{"'" unless all_numeric? }#{o.value}#{"'" unless all_numeric? }='#{o.value}: #{o.name.gsub("'", "''")}'"}.join("\n")}\n  ;"
    # "  value #{sas_domain_name}\n#{self.options.collect{|o| "    #{"'" unless self.all_numeric? }#{o[:value]}#{"'" unless self.all_numeric? }='#{o[:value]}: #{o[:name].gsub("'", "''")}'"}.join("\n")}\n  ;"
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

  def update_option_tokens!
    return if option_tokens.nil?
    transaction do
      # TODO: Delete option tokens that aren't updated?
      domain_option_ids = option_tokens.collect { |hash| hash[:domain_option_id] }.select(&:present?)
      domain_options.where.not(id: domain_option_ids).destroy_all

      option_tokens.each_with_index do |option_hash, index|
        next if option_hash[:name].blank?
        domain_option = domain_options.find_by(id: option_hash.delete(:domain_option_id))
        if domain_option
          domain_option.update(cleaned_hash(option_hash, index, domain_option))
        else
          domain_options.create(cleaned_hash(option_hash, index, nil))
        end
        # domain_option.update_from_hash!(option_hash, index)
      end
    end
  end

  def cleaned_hash(option_hash, index, domain_option)
    description = DesignOption.cleaned_description(option_hash, domain_option)
    value = DesignOption.cleaned_value(option_hash, index)
    {
      name: option_hash[:name], value: value, description: description,
      site_id: option_hash[:site_id], position: index,
      missing_code: (option_hash[:missing_code] == '1'),
      archived: (option_hash[:archived] == '1')
    }
  end
end
