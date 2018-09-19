# frozen_string_literal: true

module Engine
  module Expressions
    class VariableExp < Expression
      attr_accessor :name, :event

      def initialize(name, event: nil)
        @name = name
        @event = event if event.is_a?(::Engine::Expressions::EventExp)
      end

      def storage_name
        if @event
          "#{@name}@#{@event.name}"
        else
          @name
        end
      end
    end
  end
end
