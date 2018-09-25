# frozen_string_literal: true

module Engine
  module Expressions
    class Identifier < Expression
      def storage_name
        # Abstract function, needs to be overwritten.
      end

      def result_name
        storage_name
      end
    end
  end
end
