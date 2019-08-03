# frozen_string_literal: true

module Engine
  # Generates a expression tree from a set of tokens based on the Slice
  # Context Free Grammar. (Slice Expression Language)
  class Parser
    attr_accessor :tokens, :tree, :events, :identifiers

    def initialize(project, verbose: false)
      @project = project
      @current_position = nil
      @current_token = nil
      @next_token = nil
      @previous_token = nil
      @tree = nil
      @verbose = verbose
      @events = []
      @identifiers = []
    end

    def advance
      set_position(@current_position + 1)
    end

    def insert(token_type)
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

    def token_is?(*token_types)
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

    def identifier_designs
      @identifiers.select { |ie| ie.is_a?(::Engine::Expressions::IdentifierDesign) }
    end

    def identifier_events
      @identifiers.select { |ie| ie.is_a?(::Engine::Expressions::IdentifierEvent) }
    end

    def identifier_variables
      @identifiers.select { |ie| ie.is_a?(::Engine::Expressions::IdentifierVariable) }
    end

    def identifier_randomizations
      @identifiers.select { |ie| ie.is_a?(::Engine::Expressions::Randomized) }
    end

    private

    def recursive_descent_parser
      puts "#{"Parser".white} recursive descent parsing started..." if @verbose
      @tree = expression
    end

    def expression
      expr = xorterm

      while token_is?(:or)
        operator = @previous_token
        right = xorterm
        expr = ::Engine::Expressions::Binary.new(expr, operator, right)
      end

      expr
    end

    def xorterm
      expr = term

      while token_is?(:xor)
        operator = @previous_token
        right = term
        expr = ::Engine::Expressions::Binary.new(expr, operator, right)
      end

      expr
    end

    def term
      expr = factor

      while token_is?(:and)
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

      while token_is?(:bang_equal, :equal)
        operator = @previous_token
        right = comparison
        expr = ::Engine::Expressions::Binary.new(expr, operator, right)
      end

      expr
    end

    def comparison
      expr = between

      while token_is?(:greater, :less, :greater_equal, :less_equal)
        operator = @previous_token
        right = between
        expr = ::Engine::Expressions::Binary.new(expr, operator, right)
      end

      expr
    end

    def between
      expr = addition

      if token_is?(:between)
        operator = @previous_token
        lower = addition
        consume_token!(:and, "Missing `and` after between.")
        higher = addition
        left = ::Engine::Expressions::Binary.new(expr, ::Engine::Token.new(:greater_equal, auto: true), lower)
        right = ::Engine::Expressions::Binary.new(expr, ::Engine::Token.new(:less_equal, auto: true), higher)
        expr = ::Engine::Expressions::Binary.new(left, ::Engine::Token.new(:and), right)
      end

      expr
    end

    def addition
      expr = multiplication

      while token_is?(:minus, :plus)
        operator = @previous_token
        right = multiplication
        expr = ::Engine::Expressions::Binary.new(expr, operator, right)
      end

      expr
    end

    def multiplication
      expr = exponentiation

      while token_is?(:slash, :star)
        operator = @previous_token
        right = exponentiation
        expr = ::Engine::Expressions::Binary.new(expr, operator, right)
      end

      expr
    end

    def exponentiation
      expr = unary

      while token_is?(:power)
        operator = @previous_token
        right = unary
        expr = ::Engine::Expressions::Binary.new(expr, operator, right)
      end

      expr
    end

    def unary
      if token_is?(:bang, :minus, :plus)
        operator = @previous_token
        right = unary
        return ::Engine::Expressions::Unary.new(operator, right)
      end

      identifier_event
    end

    def identifier_event
      expr = primary
      if token_is?(:at)
        operator = @previous_token
        right = primary
        # TODO: Raise "expected an event" if right is not of type ::Engine::Expressions::IdentifierEvent
        # TODO: @identifiers[-2] also needs to be an IdentifierVariable or an IdentifierDesign
        @identifiers[-2].event = right if @identifiers[-2].respond_to?(:event)
      end
      expr
    end

    def primary
      return ::Engine::Expressions::Literal.new(false) if token_is?(:false)
      return ::Engine::Expressions::Literal.new(true) if token_is?(:true)
      return ::Engine::Expressions::Literal.new(nil) if token_is?(:nil)
      return ::Engine::Expressions::Literal.new(:entered, meta: true) if token_is?(:entered)
      return ::Engine::Expressions::Literal.new(:present, meta: true) if token_is?(:present)
      return ::Engine::Expressions::Literal.new(:missing, meta: true) if token_is?(:missing)
      return ::Engine::Expressions::Literal.new(:unentered, meta: true) if token_is?(:unentered)

      if token_is?(:number, :string)
        return ::Engine::Expressions::Literal.new(@previous_token.raw)
      end

      if token_is?(:identifier)
        variable = @project.variables.find_by(name: @previous_token.raw)
        if variable
          @previous_token.identified = true
          identifier = ::Engine::Expressions::IdentifierVariable.new(variable.name)
          @identifiers << identifier
          return identifier
        end
        event = @project.events.find_by(slug: @previous_token.raw)
        if event
          @previous_token.identified = true
          identifier = ::Engine::Expressions::IdentifierEvent.new(event.slug)
          @identifiers << identifier
          return identifier
        end
        design = @project.designs.find_by(slug: @previous_token.raw)
        if design
          @previous_token.identified = true
          identifier = ::Engine::Expressions::IdentifierDesign.new(design.slug)
          @identifiers << identifier
          return identifier
        end
      end

      if token_is?(:randomized)
        identifier = ::Engine::Expressions::Randomized.new
        @identifiers << identifier
        return identifier
      end

      if token_is?(:subject)
        identifier = ::Engine::Expressions::IdentifierSubject.new
        # TODO: This could add metadata about the subject.
        # @identifiers << identifier
        return identifier
      end

      if token_is?(:left_paren)
        expr = expression
        consume_token!(:right_paren, "Missing closing ')'.")
        return ::Engine::Expressions::Grouping.new(expr)
      end

      return ::Engine::Expressions::Literal.new(nil)
    end
  end
end
