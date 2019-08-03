# frozen_string_literal: true

module Engine
  module Expressions
    class IdentifierSubject < Identifier
      def name
        "_subject"
      end

      def storage_name
        "_s_subject"
      end
    end
  end
end
