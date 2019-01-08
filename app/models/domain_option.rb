# frozen_string_literal: true

# Defines a single option for a domain.
class DomainOption < ApplicationRecord
  # Concerns
  include Squishable
  squish :name, :value

  include Translatable
  translates :name, :description

  # Validations
  validates :domain_id, :name, :value, presence: true
  validates :value, format: { with: /\A[\w\.-]*\Z/ },
                    uniqueness: { scope: :domain_id }
  validate :prevent_value_merging

  # Relationships
  belongs_to :domain
  belongs_to :site, optional: true
  has_many :sheet_variables
  has_many :grids
  has_many :responses

  # Methods

  def value_and_name(show_values: true)
    if show_values
      "#{value}: #{name}"
    else
      name
    end
  end

  def add_domain_option!(variable: nil)
    filters = { value: value }
    filters[:variable] = variable if variable.present?
    domain.sheet_variables.where(filters).update_all(domain_option_id: id, value: nil)
    domain.grids.where(filters).update_all(domain_option_id: id, value: nil)
    domain.responses.where(filters).update_all(domain_option_id: id, value: nil)
  end

  def remove_domain_option!(variable: nil)
    filters = {}
    filters[:variable] = variable if variable.present?
    sheet_variables.where(filters).update_all(domain_option_id: nil, value: value)
    grids.where(filters).update_all(domain_option_id: nil, value: value)
    responses.where(filters).update_all(domain_option_id: nil, value: value)
  end

  def destroy
    remove_domain_option!
    super
  end

  def prevent_value_merging
    return unless changes.key?(:value)
    return if captured_values_count.zero? || other_values_count.zero?
    errors.add(:value, "merging not permitted")
  end

  def captured_values_count
    sheet_variables.count + grids.count + responses.count
  end

  def other_values_count
    domain.sheet_variables.where(value: value).count +
      domain.grids.where(value: value).count +
      domain.responses.where(value: value).count
  end

  def unmerged_values?
    other_values_count.positive?
  end
end
