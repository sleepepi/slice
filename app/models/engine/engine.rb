# frozen_string_literal: true

# Engine that interprets the Slice Context Free Grammar.
# The engine handles Parses Slice Expressions and returns Subject Sets.
module Engine
  class Engine
    attr_accessor :lexer, :parser, :interpreter, :run_ms

    def initialize(project, verbose: false)
      @project = project
      @verbose = verbose
      @lexer = ::Engine::Lexer.new(verbose: @verbose)
      @parser = ::Engine::Parser.new(verbose: @verbose)
      @interpreter = ::Engine::Interpreter.new(project, verbose: @verbose)
      puts "#{"Engine".white} initialized." if @verbose
    end

    def run(input)
      t = Time.zone.now
      puts "#{"Engine".white} started..." if @verbose
      @lexer.lexer(input.downcase)
      @lexer.tokens.each(&:print) if @verbose
      @parser.parse(@lexer.tokens)
      @parser.print_tree if @verbose
      @interpreter.variable_names = @parser.variable_names
      @interpreter.tree = @parser.tree
      @interpreter.run
      puts "...#{"DONE".white}" if @verbose
      @run_ms = ((Time.zone.now - t) * 1000).to_i
    end
  end
end
