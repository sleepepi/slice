# frozen_string_literal: true

module Engine
  module Expressions
    class IdentifierDesign < Identifier
      attr_accessor :name, :event

      def initialize(name, event: nil)
        @name = name
        @event = event if event.is_a?(::Engine::Expressions::IdentifierEvent)
      end

      def storage_name
        if @event
          "_d_#{@name}@#{@event.name}"
        else
          "_d_#{@name}"
        end
      end
    end
  end
end
