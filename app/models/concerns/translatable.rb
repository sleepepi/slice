# frozen_string_literal: true

# Translates a model attribute if the requested translation is available.
module Translatable
  extend ActiveSupport::Concern

  included do
    # Relationships
    has_many :translations, as: :translatable
  end

  # Allows attributes to be translated.
  #   include Translatable
  #   translates :name, :description
  module ClassMethods
    def translates(*attributes)
      attributes.each do |attribute|
        class_eval <<-RUBY
          def #{attribute}
            return self[:#{attribute}] if I18n.locale == I18n.default_locale
            t = translations.find_by(locale: I18n.locale, translatable_attribute: "#{attribute}")
            t&.translation.presence || self[:#{attribute}]
          end
        RUBY
      end
    end
  end
end
