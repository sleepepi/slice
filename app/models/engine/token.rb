# frozen_string_literal: true

# Represents an atomic component of the Slice Context Free Grammar.
module Engine
  class Token
    TYPES = [
      :identifier,
      :value,
      :number,
      :string,
      :minus, :plus,
      :star, :slash,
      :power,
      :bang,
      :greater, :less, :greater_equal, :less_equal, :bang_equal, :equal,
      :true, :false, :nil,
      :left_paren, :right_paren,
      :and, :xor, :or,
      :entered, :present, :missing, :unentered
    ]

    attr_accessor :token_type, :raw, :auto, :identified

    def initialize(token_type, raw: nil, auto: false)
      @token_type = token_type
      @raw = raw
      @auto = auto
      @identified = false
    end

    def print
      puts "#{token_type.to_s.upcase}#{"[#{raw}]" if raw.present?}"
    end

    def boolean_operator?
      comparison_operator? || @token_type.in?([:bang, :and, :or, :xor])
    end

    def comparison_operator?
      @token_type.in?([
        :bang_equal,
        :equal,
        :greater,
        :greater_equal,
        :less,
        :less_equal
      ])
    end
  end
end
