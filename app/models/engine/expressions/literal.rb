# frozen_string_literal: true

module Engine
  module Expressions
    class Literal < Expression
      attr_accessor :value, :meta

      def initialize(value, meta: false)
        @value = value
        @meta = meta
      end
    end
  end
end
