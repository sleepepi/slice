# frozen_string_literal: true

module Engine
  module Expressions
    class EventExp < Expression
      attr_accessor :name

      def initialize(name)
        @name = name
      end
    end
  end
end