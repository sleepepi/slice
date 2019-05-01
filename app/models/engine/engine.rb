# frozen_string_literal: true

# Engine that interprets the Slice Context Free Grammar.
# The engine handles Parses Slice Expressions and returns Subject Sets.
module Engine
  class Engine
    attr_accessor :lexer, :parser, :interpreter, :run_ms

    def initialize(project, current_user, verbose: false)
      @project = project
      @current_user = current_user
      @verbose = verbose
      @lexer = ::Engine::Lexer.new(verbose: @verbose)
      @parser = ::Engine::Parser.new(project, verbose: @verbose)
      @interpreter = ::Engine::Interpreter.new(project, verbose: @verbose)
      puts "#{"Engine".white} initialized." if @verbose
    end

    def run(input)
      t = Time.zone.now
      puts "#{"Engine".white} started..." if @verbose
      @lexer.lexer(input)
      @lexer.tokens.each(&:print) if @verbose
      @parser.parse(@lexer.tokens)
      @interpreter.parser = @parser
      @interpreter.run
      puts "...#{"DONE".white}" if @verbose
      @run_ms = ((Time.zone.now - t) * 1000).to_i
      # Rails.logger.debug "Memory Used: " + (`ps -o rss -p #{$$}`.strip.split.last.to_i / 1024).to_s + " MB"
      unless input.blank?
        EngineRun.create(
          project: @project,
          user: @current_user,
          expression: input,
          runtime_ms: @run_ms,
          subjects_count: @interpreter.subjects_count,
          sheets_count: @interpreter.sheets.count
        )
      end
    end

    def subjects_count
      @interpreter.subjects_count
    end

    def subject_ids
      @interpreter.sobjects.collect { |_, sobject| sobject.subject_id }
    end
  end
end
