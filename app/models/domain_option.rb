# frozen_string_literal: true

# Defines a single option for a domain.
class DomainOption < ApplicationRecord
  # Concerns
  include Squishable
  squish :name, :value

  # Validations
  validates :domain_id, :name, :value, presence: true
  validates :value, format: { with: /\A[\w\.-]*\Z/ },
                    uniqueness: { scope: :domain_id }
  validate :prevent_value_merging

  # Relationships
  belongs_to :domain
  belongs_to :site

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

  # TODO: Update sheet_variables and grids to use `value` instead of `response`
  def add_domain_option!
    domain.sheet_variables.where(response: value).update_all(domain_option_id: id, response: nil)
    domain.grids.where(response: value).update_all(domain_option_id: id, response: nil)
    domain.responses.where(value: value).update_all(domain_option_id: id, value: nil)
  end

  # TODO: Update sheet_variables and grids to use `value` instead of `response`
  def remove_domain_option!
    sheet_variables.update_all(domain_option_id: nil, response: value)
    grids.update_all(domain_option_id: nil, response: value)
    responses.update_all(domain_option_id: nil, value: value)
  end

  def destroy
    remove_domain_option!
    super
  end

  def prevent_value_merging
    return if captured_values_count.zero? || other_values_count.zero?
    errors.add(:value, 'merging not permitted')
  end

  def captured_values_count
    sheet_variables.count + grids.count + responses.count
  end

  def other_values_count
    domain.sheet_variables.where(response: value).count +
      domain.grids.where(response: value).count +
      domain.responses.where(value: value).count
  end
end
