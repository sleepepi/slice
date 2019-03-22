# frozen_string_literal: true

# Defines the position of sections and questions on designs. Design options also
# have associated branching logic, and can be set as required, recommended, or
# optional.
class DesignOption < ApplicationRecord
  # Constants
  REQUIREMENTS = [
    ["Not Required", ""],
    ["Recommended", "recommended"],
    ["Required", "required"]
  ]

  # Validations
  validates :design_id, presence: true
  validates :variable_id, uniqueness: { scope: [:design_id] }, allow_nil: true
  validates :section_id, uniqueness: { scope: [:design_id] }, allow_nil: true

  # Relationships
  belongs_to :design
  belongs_to :variable, optional: true
  belongs_to :section, optional: true, dependent: :destroy

  # Concerns
  include Translatable

  # Methods
  def readable_branching_logic
    branching_logic.to_s.gsub(/\#{(\d+)}/) do
      v = design.variables.find_by(id: $1)
      if v
        v.name
      else
        $1
      end
    end
  end

  def branching_logic=(branching_logic)
    branching_logic.to_s.gsub!(/\w+/) do |word|
      v = design.variables.find_by(name: word)
      if v
        "\#{#{v.id}}"
      else
        word
      end
    end
    self[:branching_logic] = branching_logic.try(:strip)
  end

  def requirement_string
    element = REQUIREMENTS.find { |_label, value| value == requirement }
    if element
      element.first
    else
      "Not Required"
    end
  end

  def required?
    requirement == "required"
  end

  def recommended?
    requirement == "recommended"
  end

  def optional?
    requirement == "optional" || requirement.blank?
  end

  def self.cleaned_value(hash, index)
    if hash[:value].blank?
      index + 1
    else
      hash[:value]
    end
  end

  def save_translation!(section_params, variable_params)
    if section
      section.save_translation!(section_params)
    else # variable
      variable.save_translation!(variable_params)
    end
  end
end
