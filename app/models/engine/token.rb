# frozen_string_literal: true

# Represents an atomic component of the Slice Context Free Grammar.
module Engine
  class Token
    TYPES = [
      :identifier,
      :value,
      :number,
      :minus, :plus,
      :star, :slash,
      :bang,
      :greater, :less, :greater_equal, :less_equal, :bang_equal, :equal,
      :true, :false, :nil,
      :left_paren, :right_paren,
      :and, :xor, :or,
      :entered, :any, :missing, :unentered
    ]

    attr_accessor :token_type, :raw, :auto

    def initialize(token_type, raw: nil, auto: false)
      @token_type = token_type
      @raw = raw
      @auto = auto
    end

    def print
      puts "#{token_type.to_s.upcase}#{"[#{raw}]" if raw.present?}"
    end

    def boolean_operator?
      @token_type.in?([
        :bang,
        :bang_equal,
        :equal,
        :greater,
        :greater_equal,
        :less,
        :less_equal,
        :and,
        :or,
        :xor
      ])
    end
  end
end
