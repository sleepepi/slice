# frozen_string_literal: true

# Removes white space from model attributes
module Squishable
  extend ActiveSupport::Concern

  # Allows attributes to be squished.
  #   include Squishable
  #   squish :name, :description
  module ClassMethods
    def squish(*attributes)
      attributes.each do |attribute|
        class_eval <<-RUBY
          def #{attribute}=(attribute)
            self[:#{attribute}] = attribute.try(:squish)
          end
        RUBY
      end
    end
  end
end
