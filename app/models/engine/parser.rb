# frozen_string_literal: true

module Engine
  # Generates a expression tree from a set of tokens based on the Slice
  # Context Free Grammar. (Slice Expression Language)
  class Parser
    attr_accessor :tokens, :tree

    def initialize(verbose: false)
      @current_position = nil
      @current_token = nil
      @next_token = nil
      @previous_token = nil
      @tree = nil
      @verbose = verbose
    end

    def advance
      set_position(@current_position + 1)
    end

    def insert(token_type)
      # puts @tokens
      @tokens.insert(@current_position, ::Engine::Token.new(token_type, auto: true))
    end

    def parse(tokens)
      @tokens = tokens
      set_position(0)
      recursive_descent_parser
    end

    def set_position(index)
      @current_position = index
      @previous_token = @current_position.positive? ? tokens[@current_position - 1] : nil
      @current_token = tokens[@current_position]
      @next_token = tokens[@current_position + 1]
    end

    def token_is?(token_types)
      if @current_token&.token_type.in?(token_types)
        advance
        true
      else
        false
      end
    end

    def consume_token!(token_type, message)
      if @current_token&.token_type == token_type
        advance
      else
        insert(token_type)
        advance
      end
    end

    def print_tree
      puts "#{"@tree".green}: #{@tree}"
    end

    def variable_names
      @tokens.select { |t| t.token_type == :variable }.collect { |t| t.raw }
    end

    private

    def recursive_descent_parser
      puts "#{"Parser".white} recursive descent parsing started..." if @verbose
      @tree = expression
    end

    def expression
      expr = term

      while token_is?([:or])
        operator = @previous_token
        right = term
        expr = ::Engine::Expressions::Binary.new(expr, operator, right)
      end

      expr
    end

    def term
      expr = factor

      while token_is?([:and])
        operator = @previous_token
        right = factor
        expr = ::Engine::Expressions::Binary.new(expr, operator, right)
      end

      expr
    end

    def factor
      equality
    end

    def equality
      expr = comparison

      while token_is?([:bang_equal, :equal])
        operator = @previous_token
        right = comparison
        expr = ::Engine::Expressions::Binary.new(expr, operator, right)
      end

      expr
    end

    def comparison
      expr = between

      while token_is?([:greater, :less, :greater_equal, :less_equal])
        operator = @previous_token
        right = between
        expr = ::Engine::Expressions::Binary.new(expr, operator, right)
      end

      expr
    end

    def between
      expr = addition

      if token_is?([:between])
        operator = @previous_token
        lower = addition
        consume_token!(:and, "Missing `and` after between.")
        higher = addition
        expr = ::Engine::Expressions::Between.new(expr, lower, higher)
      end

      expr
    end

    def addition
      expr = multiplication

      while token_is?([:minus, :plus])
        operator = @previous_token
        right = multiplication
        expr = ::Engine::Expressions::Binary.new(expr, operator, right)
      end

      expr
    end

    def multiplication
      expr = unary

      while token_is?([:slash, :star])
        operator = @previous_token
        right = unary
        expr = ::Engine::Expressions::Binary.new(expr, operator, right)
      end

      expr
    end

    def unary
      if token_is?([:bang, :minus, :plus])
        operator = @previous_token
        right = unary
        return ::Engine::Expressions::Unary.new(operator, right)
      end

      primary
    end

    def primary
      return ::Engine::Expressions::Literal(false) if token_is?([:false])
      return ::Engine::Expressions::Literal(true) if token_is?([:true])
      return ::Engine::Expressions::Literal(nil) if token_is?([:nil])

      if token_is?([:number, :string])
        return ::Engine::Expressions::Literal.new(@previous_token.raw)
      end

      if token_is?([:variable])
        return ::Engine::Expressions::VariableExp.new(@previous_token.raw)
      end

      if token_is?([:left_paren])
        expr = expression
        consume_token!(:right_paren, "Missing closing ')'.")
        return ::Engine::Expressions::Grouping.new(expr)
      end
    end
  end
end
