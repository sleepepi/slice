# frozen_string_literal: true

# Helps set language for translated slice forms.
module World
  DEFAULT_LANGUAGE = World::Languages::English
  LANGUAGES = {
    en: World::Languages::English,
    es: World::Languages::Spanish,
    :"fr-CA" => World::Languages::FrenchCanadian
  }

  mattr_accessor :default_language
  mattr_accessor :language
  @@default_language = @@language = :en

  def self.for(code)
    (LANGUAGES[code&.to_sym] || DEFAULT_LANGUAGE).new
  end

  def self.available_languages
    LANGUAGES.collect { |_, klass| klass.new }
  end

  def self.default_language?
    @@default_language == @@language
  end

  def self.translate_language?
    !default_language?
  end
end
