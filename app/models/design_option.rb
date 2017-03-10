# frozen_string_literal: true

# Defines the position of sections and questions on designs. Design options also
# have associated branching logic, and can be set as recommended or required
class DesignOption < ApplicationRecord
  REQUIRED = [['Not Required', ''], ['Recommended', 'recommended'], ['Required', 'required']]

  # Validations
  validates :design_id, presence: true
  validates :variable_id, uniqueness: { scope: [:design_id] }, allow_nil: true
  validates :section_id, uniqueness: { scope: [:design_id] }, allow_nil: true

  # Relationships
  belongs_to :design
  belongs_to :variable
  belongs_to :section, dependent: :destroy

  # Methods

  def required_string
    element = REQUIRED.find { |_label, value| value == required }
    if element
      element.first
    else
      'Not Required'
    end
  end

  def self.cleaned_description(hash, domain_option)
    if hash.key?(:description)
      hash[:description]
    elsif domain_option
      domain_option.description
    end
  end

  def self.cleaned_value(hash, index)
    if hash[:value].blank?
      index + 1
    else
      hash[:value]
    end
  end
end
