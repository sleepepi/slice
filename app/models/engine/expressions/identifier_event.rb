# frozen_string_literal: true

module Engine
  module Expressions
    class IdentifierEvent < Expression
      attr_accessor :name

      def initialize(name)
        @name = name
      end

      def storage_name
        "_e_#{@name}"
      end
    end
  end
end
