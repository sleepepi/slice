# frozen_string_literal: true

# Translates a model attribute if the requested translation is available.
module Translatable
  extend ActiveSupport::Concern

  included do
    # Relationships
    has_many :translations, as: :translatable

    def self.translatable_attributes
      class_variable_get(:@@translatable_attributes)
    end
  end

  # Allows attributes to be translated.
  #   include Translatable
  #   translates :name, :description
  module ClassMethods
    def translates(*attributes)
      class_variable_set(:@@translatable_attributes, attributes.uniq)
      attributes.each do |attribute|
        class_eval <<-RUBY
          # If no language code is provided, try to find translation or fallback to default.
          # If language code is equal to default language, fallback to default.
          # If language code is specified, then find translation or return nil.
          def #{attribute}(language_code = nil)
            if language_code.nil?
              return self[:#{attribute}] if World.default_language?
              t = translations.find_by(language_code: World.language, translatable_attribute: "#{attribute}")
              t&.translation.presence || self[:#{attribute}]
            elsif language_code.to_s == World.default_language.to_s
              return self[:#{attribute}]
            else
              t = translations.find_by(language_code: language_code, translatable_attribute: "#{attribute}")
              t&.translation
            end
          end
        RUBY
      end
    end
  end

  def save_object_translation!(object, attribute, translation)
    t = object.translations.where(language_code: World.language, translatable_attribute: attribute).first_or_create
    t.update(translation: translation.presence)
  end

  def translation_missing?(attribute)
    self[attribute.to_sym].present? && send(attribute, World.language).blank?
  end
end
