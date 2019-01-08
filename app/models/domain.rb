# frozen_string_literal: true

# Represents a finite set of options for a given variable.
class Domain < ApplicationRecord
  # Concerns
  include Deletable
  include Searchable
  include Translatable

  attr_accessor :option_tokens

  # Validations
  validates :name, :display_name, :project_id, :user_id, presence: true
  validates :name, format: { with: /\A[a-z]\w*\Z/i },
                   length: { maximum: 30 },
                   uniqueness: { scope: [:deleted, :project_id] }

  # Relationships
  belongs_to :user
  belongs_to :project
  has_many :domain_options, -> { order(Arel.sql("position nulls last"), :id) }
  has_many :variables, -> { current }
  has_many :sheet_variables, through: :variables
  has_many :grids, through: :variables
  has_many :responses, through: :variables

  # Methods

  def self.searchable_attributes
    %w(name description)
  end

  def missing_codes?
    domain_options.where(missing_code: true).count > 0
  end

  def mutually_exclusives?
    domain_options.where(mutually_exclusive: true).count > 0
  end

  def descriptions?
    domain_options.where.not(description: [nil, ""]).count > 0
  end

  def sites?
    domain_options.where.not(site_id: nil).count > 0
  end

  def archived_options?
    domain_options.where(archived: true).count > 0
  end

  # Returns true if all options are integers
  # TODO: Check where this is referenced for optimization
  # TODO: Currently doesn't allow decimals.
  def all_numeric?
    @all_numeric ||= begin
      domain_options.pluck(:value).count { |v| !(v =~ /^[-+]?[0-9]+$/) }.zero?
    end
  end

  def sas_value_domain
    "  value #{sas_domain_name}\n#{domain_options.collect { |o| "    #{"'" unless all_numeric? }#{o.value}#{"'" unless all_numeric?}='#{o.value}: #{o.name.gsub("'", "''")}'" }.join("\n")}\n  ;"
  end

  def sas_domain_name
    "#{'$' unless all_numeric?}#{name}f"
  end

  def self.clean_option_tokens(params)
    (params[:option_tokens] || []).each_with_index do |option, index|
      params[:option_tokens][index][:value] = (index + 1).to_s if option[:name].present? && option[:value].blank?
    end
    params
  end

  def update_option_tokens!
    return if option_tokens.nil?
    domain_option_ids = option_tokens.collect { |hash| hash[:domain_option_id] }.select(&:present?)
    domain_options.where.not(id: domain_option_ids).destroy_all
    all_domain_options = domain_options.includes(:domain).to_a
    option_tokens.each_with_index do |option_hash, index|
      next if option_hash[:name].blank? && !World.translate_language?
      domain_option = all_domain_options.find { |o| o.id == option_hash[:domain_option_id].to_i }
      if domain_option
        original_value = domain_option.value
        if domain_option.update(cleaned_hash(option_hash, index))
          domain_option.add_domain_option! unless original_value == domain_option.value
          if World.translate_language?
            [:name, :description].each do |attribute|
              save_object_translation!(domain_option, attribute, option_hash[attribute]) if option_hash.key?(attribute)
            end
          end
        else
          # TODO: Domain option has errors. (can be caused by merging values)
        end
      else
        domain_option = domain_options.create(cleaned_hash(option_hash, index))
        domain_option.add_domain_option! unless domain_option.new_record?
      end
    end
  end

  def cleaned_hash(option_hash, index)
    hash = {}
    if World.default_language?
      hash[:name] = option_hash[:name]
      hash[:description] = option_hash[:description] if option_hash.key?(:description)
    end
    hash[:position] = index
    hash[:value] = DesignOption.cleaned_value(option_hash, index)
    hash[:site_id] = option_hash[:site_id]
    hash[:missing_code] = (option_hash[:missing_code] == "1")
    hash[:archived] = (option_hash[:archived] == "1")
    hash
  end

  def add_domain_values!(variable)
    domain_options.each { |opt| opt.add_domain_option!(variable: variable) }
  end

  def remove_domain_values!(variable)
    domain_options.each { |opt| opt.remove_domain_option!(variable: variable) }
  end
end
