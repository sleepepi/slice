# frozen_string_literal: true

module World
  module Languages
    class FrenchCanadian < Default # :nodoc:
      def initialize
        @code = :"fr-CA"
        @names = {
          en: "French Canadian",
          es: "Francés canadiense",
          "fr-CA": "Français Canadien"
        }
        @special_characters = [
          { "â" => { simple: "a", latex: "\\\\^a" } },
          { "à" => { simple: "a", latex: "\\\\`a" } },
          { "ä" => { simple: "a", latex: "\\\\\"a" } },
          { "ç" => { simple: "c", latex: "\\\\c{c}" } },
          { "é" => { simple: "e", latex: "\\\\'e" } },
          { "è" => { simple: "e", latex: "\\\\`e" } },
          { "ê" => { simple: "e", latex: "\\\\^e" } },
          { "ë" => { simple: "e", latex: "\\\\\"e" } },
          { "î" => { simple: "i", latex: "\\\\^i" } },
          { "ï" => { simple: "i", latex: "\\\\\"i" } },
          { "ô" => { simple: "o", latex: "\\\\^o" } },
          { "ù" => { simple: "u", latex: "\\\\`u" } },
          { "û" => { simple: "u", latex: "\\\\^u" } },
          { "ü" => { simple: "u", latex: "\\\\\"u" } },
          { "œ" => { simple: "oe", latex: "\\\\oe" } },
          { "«" => { simple: "<<", latex: "\\\\guillemotleft" } },
          { "»" => { simple: ">>", latex: "\\\\guillemotright" } }
        ]
      end
    end
  end
end
