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
            return self[:#{attribute}] if World.default_language?
            t = translations.find_by(language_code: World.language, translatable_attribute: "#{attribute}")
            t&.translation.presence || self[:#{attribute}]
          end
        RUBY
      end
    end
  end
end
