# frozen_string_literal: true

# Represents an atomic component of the Slice Context Free Grammar.
module Engine
  class Token
    TYPES = [
      :variable,
      :value,
      :number,
      :minus,
      :plus,
      :star,
      :slash,
      :bang,
      :greater, :less, :greater_equal, :less_equal, :bang_equal, :equal,
      :false, :true, :nil,
      :left_paren, :right_paren
    ]

    attr_accessor :token_type, :raw

    def initialize(token_type, raw: nil)
      @token_type = token_type
      @raw = raw
    end

    def print
      puts "#{token_type.to_s.upcase}#{"[#{raw}]" if raw.present?}"
    end
  end
end
