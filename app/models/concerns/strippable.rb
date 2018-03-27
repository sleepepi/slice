# frozen_string_literal: true

# Removes white space from model attributes.
module Strippable
  extend ActiveSupport::Concern

  # Allows attributes to be stripped.
  #   include Strippable
  #   strip :name, :description
  module ClassMethods
    def strip(*attributes)
      attributes.each do |attribute|
        class_eval <<-RUBY
          def #{attribute}=(attribute)
            super(attribute.try(:strip))
          end
        RUBY
      end
    end
  end
end
