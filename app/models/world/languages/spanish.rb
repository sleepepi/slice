# frozen_string_literal: true

module World
  module Languages
    class Spanish < Default # :nodoc:
      def initialize
        @code = :es
        @names = {
          en: "Spanish",
          es: "Español",
          "fr-CA": "Espagnol"
        }
        @special_characters = [
          { "á" => { simple: "a", latex: "\\\\'a" } },
          { "é" => { simple: "e", latex: "\\\\'e" } },
          { "í" => { simple: "i", latex: "\\\\'i" } },
          { "ó" => { simple: "o", latex: "\\\\'o" } },
          { "ú" => { simple: "u", latex: "\\\\'u" } },
          { "¿" => { simple: "?", latex: "?`" } },
          { "¡" => { simple: "!", latex: "!`" } },
          { "ü" => { simple: "u", latex: "\\\\\"u" } },
          { "ñ" => { simple: "n", latex: "\\\\~n" } }
        ]
      end
    end
  end
end
