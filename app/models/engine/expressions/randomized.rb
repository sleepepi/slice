# frozen_string_literal: true

module Engine
  module Expressions
    class Randomized < Expression
      def name
        "_randomized"
      end

      def storage_name
        "_randomized"
      end

      def result_name
        storage_name
      end
    end
  end
end
