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

  def save_translation!(section_params, variable_params, locale)
    if section
      name_t = section_params.delete(:name)
      desc_t = section_params.delete(:description)
      save_object_translation!(section, "name", name_t, locale)
      save_object_translation!(section, "description", desc_t, locale)
      section.update(section_params)
    else # variable
      [:display_name, :field_note].each do |attribute|
        next unless variable_params.key?(attribute)
        translation = variable_params.delete(attribute)
        save_object_translation!(variable, attribute, translation, I18n.locale)
      end
      result = variable.update(variable_params)
      variable.update_grid_tokens! if result
      result
    end
  end

  def save_object_translation!(object, attribute, translation, locale)
    t = object.translations.where(locale: locale, translatable_attribute: attribute).first_or_create
    t.update(translation: translation.presence)
  end
end
