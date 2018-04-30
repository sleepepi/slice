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
          def #{attribute}
            return self[:#{attribute}] if World.default_language?
            t = translations.find_by(language_code: World.language, translatable_attribute: "#{attribute}")
            t&.translation.presence || self[:#{attribute}]
          end
        RUBY
      end
    end
  end
end
