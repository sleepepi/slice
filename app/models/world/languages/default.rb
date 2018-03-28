# frozen_string_literal: true

module World
  module Languages
    class Default # :nodoc:
      attr_reader :code

      def initialize
        @code = nil
        @names = {}
      end

      # Returns name in its own language if the user's chosen locale (I18n) is
      # not provided or if the translation does not exist.
      def name(code = nil)
        @names[code&.to_sym || @code] || @names[@code]
      end
    end
  end
end
