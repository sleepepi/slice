# frozen_string_literal: true

require "test_helper"

# Test preparing values for storing in database.
class EngineTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test "should parse empty" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("")
    assert_equal [], engine.lexer.tokens.collect(&:token_type)
    assert_equal 0, engine.interpreter.subjects_count
  end

  test "should parse nil" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("nil")
    assert_equal [:nil], engine.lexer.tokens.collect(&:token_type)
    assert_equal 0, engine.interpreter.subjects_count
  end

  test "should parse null" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("null")
    assert_equal [:nil], engine.lexer.tokens.collect(&:token_type)
    assert_equal 0, engine.interpreter.subjects_count
  end

  test "should parse false" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("false")
    assert_equal [:false], engine.lexer.tokens.collect(&:token_type)
    assert_equal 0, engine.interpreter.subjects_count
  end

  test "should parse true" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("true")
    assert_equal [:true], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse integer" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("42")
    assert_equal [:number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse negative integer" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("-42")
    assert_equal [:minus, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse positive integer" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("+42")
    assert_equal [:plus, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse decimal" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run(".31416")
    assert_equal [:number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse decimal with leading zero" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("0.31416")
    assert_equal [:number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse negative decimal" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("-.31416")
    assert_equal [:minus, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse decimal followed by expression" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run(".31416 > 5")
    assert_equal [:number, :greater, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 0, engine.interpreter.subjects_count
  end

  test "should parse string" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run('"1"')
    assert_equal [:string], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse string with quotes" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run('"Use \"air quotes\" when making a joke."')
    assert_equal [:string], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse identifier variable" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large_number")
    assert_equal [:identifier], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse identifier design" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("anthropometry")
    assert_equal [:identifier], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse identifier event" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("event-one")
    assert_equal [:identifier], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse equal" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("=")
    assert_equal [:equal], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse not" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("!")
    assert_equal [:bang], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse greater" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run(">")
    assert_equal [:greater], engine.lexer.tokens.collect(&:token_type)
    assert_equal 0, engine.interpreter.subjects_count
  end

  test "should parse less" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("<")
    assert_equal [:less], engine.lexer.tokens.collect(&:token_type)
    assert_equal 0, engine.interpreter.subjects_count
  end

  test "should not parse unrecognized symbol" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("`")
    assert_equal [], engine.lexer.tokens.collect(&:token_type)
    assert_equal 0, engine.interpreter.subjects_count
  end

  # Test "not" operator.
  test "should parse not nil" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("!nil")
    assert_equal [:bang, :nil], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse not false" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("!false")
    assert_equal [:bang, :false], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse not true" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("!true")
    assert_equal [:bang, :true], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse not number" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("!42")
    assert_equal [:bang, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse not decimal" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("!.31416")
    assert_equal [:bang, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse not identifier variable" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("!large_number")
    assert_equal [:bang, :identifier], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse not identifier design" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("!anthropometry")
    assert_equal [:bang, :identifier], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse not identifier event" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("!event-one")
    assert_equal [:bang, :identifier], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse not parentheses" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("!(1=1)")
    assert_equal [:bang, :left_paren, :number, :equal, :number, :right_paren], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse equality" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("1 = 1")
    assert_equal [:number, :equal, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse equality alias ==" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("1 == 1")
    assert_equal [:number, :equal, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse equality alias is" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("1 is 1")
    assert_equal [:number, :equal, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse inequality" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("1 != 1")
    assert_equal [:number, :bang_equal, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 0, engine.interpreter.subjects_count
  end

  test "should parse equality on left side" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("true and (1 = 1)")
    assert_equal [:true, :and, :left_paren, :number, :equal, :number, :right_paren], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse equality on right side" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("(1 = 1) and true")
    assert_equal [:left_paren, :number, :equal, :number, :right_paren, :and, :true], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should compare identifier variable greater than literal" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large_number > 20")
    assert_equal [:identifier, :greater, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 2, engine.interpreter.subjects_count
    assert_equal 2, engine.interpreter.sheets.count
  end

  test "should compare literal less than identifier variable" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("20 < large_number")
    assert_equal [:number, :less, :identifier], engine.lexer.tokens.collect(&:token_type)
    assert_equal 2, engine.interpreter.subjects_count
    assert_equal 2, engine.interpreter.sheets.count
  end

  test "should compare identifier variable greater than or equal to literal" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large_number >= 20")
    assert_equal [:identifier, :greater_equal, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 3, engine.interpreter.subjects_count
    assert_equal 4, engine.interpreter.sheets.count
  end

  test "should compare literal less than or equal to identifier variable" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("20 <= large_number")
    assert_equal [:number, :less_equal, :identifier], engine.lexer.tokens.collect(&:token_type)
    assert_equal 3, engine.interpreter.subjects_count
    assert_equal 4, engine.interpreter.sheets.count
  end

  test "should compare identifier variable greater than identifier variable" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large_number > small_number")
    assert_equal [:identifier, :greater, :identifier], engine.lexer.tokens.collect(&:token_type)
    assert_equal 2, engine.interpreter.subjects_count
    assert_equal 5, engine.interpreter.sheets.count
  end

  test "should compare identifier variable less than identifier variable" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large_number < small_number")
    assert_equal [:identifier, :less, :identifier], engine.lexer.tokens.collect(&:token_type)
    assert_equal 1, engine.interpreter.subjects_count
    assert_equal 2, engine.interpreter.sheets.count
  end

  # Test variable identifier presence.
  test "should parse entered identifier variable" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large_number is entered")
    assert_equal [:identifier, :equal, :entered], engine.lexer.tokens.collect(&:token_type)
    assert_equal 4, engine.interpreter.subjects_count
    assert_equal 5, engine.interpreter.sheets.count
  end

  test "should parse entered identifier variable on right" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("entered = large_number")
    assert_equal [:entered, :equal, :identifier], engine.lexer.tokens.collect(&:token_type)
    assert_equal 4, engine.interpreter.subjects_count
    assert_equal 5, engine.interpreter.sheets.count
  end

  test "should parse is not entered identifier variable" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large_number != entered")
    assert_equal [:identifier, :bang_equal, :entered], engine.lexer.tokens.collect(&:token_type)
    assert_equal 3, engine.interpreter.subjects_count
    assert_equal 1, engine.interpreter.sheets.count
  end

  test "should parse present identifier variable" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large_number is present")
    assert_equal [:identifier, :equal, :present], engine.lexer.tokens.collect(&:token_type)
    assert_equal 3, engine.interpreter.subjects_count
    assert_equal 4, engine.interpreter.sheets.count
  end

  test "should parse is not present identifier variable" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large_number != present")
    assert_equal [:identifier, :bang_equal, :present], engine.lexer.tokens.collect(&:token_type)
    assert_equal 4, engine.interpreter.subjects_count
    assert_equal 2, engine.interpreter.sheets.count
  end

  test "should parse present identifier variable on right" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("present = large_number")
    assert_equal [:present, :equal, :identifier], engine.lexer.tokens.collect(&:token_type)
    assert_equal 3, engine.interpreter.subjects_count
    assert_equal 4, engine.interpreter.sheets.count
  end

  test "should parse missing identifier variable" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large_number is missing")
    assert_equal [:identifier, :equal, :missing], engine.lexer.tokens.collect(&:token_type)
    assert_equal 4, engine.interpreter.subjects_count
    assert_equal 2, engine.interpreter.sheets.count
  end

  test "should parse is not missing identifier variable" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large_number != missing")
    assert_equal [:identifier, :bang_equal, :missing], engine.lexer.tokens.collect(&:token_type)
    assert_equal 3, engine.interpreter.subjects_count
    assert_equal 4, engine.interpreter.sheets.count
  end

  test "should parse missing identifier variable on right" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("missing = large_number")
    assert_equal [:missing, :equal, :identifier], engine.lexer.tokens.collect(&:token_type)
    assert_equal 4, engine.interpreter.subjects_count
    assert_equal 2, engine.interpreter.sheets.count
  end

  test "should parse unentered identifier variable" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large_number is unentered")
    assert_equal [:identifier, :equal, :unentered], engine.lexer.tokens.collect(&:token_type)
    assert_equal 3, engine.interpreter.subjects_count
    assert_equal 1, engine.interpreter.sheets.count
  end

  test "should parse is not unentered identifier variable" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large_number != unentered")
    assert_equal [:identifier, :bang_equal, :unentered], engine.lexer.tokens.collect(&:token_type)
    assert_equal 4, engine.interpreter.subjects_count
    assert_equal 5, engine.interpreter.sheets.count
  end

  test "should parse unentered identifier variable on right" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("unentered = large_number")
    assert_equal [:unentered, :equal, :identifier], engine.lexer.tokens.collect(&:token_type)
    assert_equal 3, engine.interpreter.subjects_count
    assert_equal 1, engine.interpreter.sheets.count
  end

  test "should parse blank identifier variable" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large_number is blank")
    assert_equal [:identifier, :equal, :unentered], engine.lexer.tokens.collect(&:token_type)
    assert_equal 3, engine.interpreter.subjects_count
    assert_equal 1, engine.interpreter.sheets.count
  end

  test "should parse blank identifier design" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large-number is blank")
    assert_equal [:identifier, :equal, :unentered], engine.lexer.tokens.collect(&:token_type)
    assert_equal 1, engine.interpreter.subjects_count
    assert_equal 0, engine.interpreter.sheets.count
  end

  test "should parse blank identifier event" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("event-two is blank")
    assert_equal [:identifier, :equal, :unentered], engine.lexer.tokens.collect(&:token_type)
    assert_equal 6, engine.interpreter.subjects_count
    assert_equal 0, engine.interpreter.sheets.count
  end

  # Test comparison of identifiers and literals.
  test "should compare identifier variable to literal" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large_number = 20")
    assert_equal [:identifier, :equal, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 2, engine.interpreter.subjects_count
    assert_equal 2, engine.interpreter.sheets.count
  end

  test "should subtract literal and identifier variable" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("0-large_number = -20")
    assert_equal [:number, :minus, :identifier, :equal, :minus, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 2, engine.interpreter.subjects_count
    assert_equal 2, engine.interpreter.sheets.count
  end

  test "should return nothing without parentheses" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large_number * 5 - 4 = 100")
    assert_equal [:identifier, :star, :number, :minus, :number, :equal, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 0, engine.interpreter.subjects_count
    assert_equal 0, engine.interpreter.sheets.count
  end

  test "should respect precedence of parentheses" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large_number * (5 - 4) = 100")
    assert_equal [:identifier, :star, :left_paren, :number, :minus, :number, :right_paren, :equal, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 1, engine.interpreter.subjects_count
    assert_equal 1, engine.interpreter.sheets.count
  end

  test "should parse identifier between literals" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("small_number between 0 and 100")
    assert_equal [:identifier, :between, :number, :and, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 3, engine.interpreter.subjects_count
    assert_equal 3, engine.interpreter.sheets.count
  end

  test "should parse identifier between identifiers" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("small_number between animals and large_number")
    assert_equal [:identifier, :between, :identifier, :and, :identifier], engine.lexer.tokens.collect(&:token_type)
    assert_equal 2, engine.interpreter.subjects_count
    assert_equal 5, engine.interpreter.sheets.count
  end

  # Test simple boolean operations.
  test "should parse true and true" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("true and true")
    assert_equal [:true, :and, :true], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse true or true" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("true or true")
    assert_equal [:true, :or, :true], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse true xor true" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("true xor true")
    assert_equal [:true, :xor, :true], engine.lexer.tokens.collect(&:token_type)
    assert_equal 0, engine.interpreter.subjects_count
  end

  test "should parse true and false" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("true and false")
    assert_equal [:true, :and, :false], engine.lexer.tokens.collect(&:token_type)
    assert_equal 0, engine.interpreter.subjects_count
  end

  test "should parse true or false" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("true or false")
    assert_equal [:true, :or, :false], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse true xor false" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("true xor false")
    assert_equal [:true, :xor, :false], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse false and true" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("false and true")
    assert_equal [:false, :and, :true], engine.lexer.tokens.collect(&:token_type)
    assert_equal 0, engine.interpreter.subjects_count
  end

  test "should parse false or true" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("false or true")
    assert_equal [:false, :or, :true], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse false xor true" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("false xor true")
    assert_equal [:false, :xor, :true], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should parse false and false" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("false and false")
    assert_equal [:false, :and, :false], engine.lexer.tokens.collect(&:token_type)
    assert_equal 0, engine.interpreter.subjects_count
  end

  test "should parse false or false" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("false or false")
    assert_equal [:false, :or, :false], engine.lexer.tokens.collect(&:token_type)
    assert_equal 0, engine.interpreter.subjects_count
  end

  test "should parse false xor false" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("false xor false")
    assert_equal [:false, :xor, :false], engine.lexer.tokens.collect(&:token_type)
    assert_equal 0, engine.interpreter.subjects_count
  end

  # Test addition
  test "should add number and number" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("32 + 10")
    assert_equal [:number, :plus, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should add variable identifier and number" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large_number + 42")
    assert_equal [:identifier, :plus, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should add variable identifier and variable identifier" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large_number + small_number")
    assert_equal [:identifier, :plus, :identifier], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should add string and string" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("\"hot\"+\"dog\"")
    assert_equal [:string, :plus, :string], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  # Test subtraction
  test "should subtract number and number" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("55 - 13")
    assert_equal [:number, :minus, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should subtract variable identifier and number" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("small_number - 42")
    assert_equal [:identifier, :minus, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should subtract variable identifier and variable identifier" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large_number - small_number")
    assert_equal [:identifier, :minus, :identifier], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  # Test multiplication
  test "should multiply number and number" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("3 * 14")
    assert_equal [:number, :star, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should multiply variable identifier and number" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("small_number * 1")
    assert_equal [:identifier, :star, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should multiply variable identifier and variable identifier" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large_number * small_number")
    assert_equal [:identifier, :star, :identifier], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should multiply string and number" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("\"hello!\" * 3")
    assert_equal [:string, :star, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  # Test division
  test "should divide number and number" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("42 / 14")
    assert_equal [:number, :slash, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should divide variable identifier and number" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("small_number / 3")
    assert_equal [:identifier, :slash, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should divide variable identifier and variable identifier" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large_number / small_number")
    assert_equal [:identifier, :slash, :identifier], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should divide number by zero and return nil" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("42 / 0")
    assert_equal [:number, :slash, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  # Test exponentiation
  test "should raise number to number" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("2 ^ 10")
    assert_equal [:number, :power, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should raise variable identifier to number" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("small_number ^ 3")
    assert_equal [:identifier, :power, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should raise variable identifier to variable identifier" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large_number ^ small_number")
    assert_equal [:identifier, :power, :identifier], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  test "should raise zero by zero and return nil" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("0 ^ 0")
    assert_equal [:number, :power, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 7, engine.interpreter.subjects_count
  end

  # Test auto-corrections for common syntax errors.
  test "should correct identifier between literals with missing and" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("small_number between 0 100")
    assert_equal [:identifier, :between, :number, :and, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 3, engine.interpreter.subjects_count
    assert_equal 3, engine.interpreter.sheets.count
  end

  test "should correct expression with missing right parenthesis" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large_number = (19 + 1")
    assert_equal [:identifier, :equal, :left_paren, :number, :plus, :number, :right_paren], engine.lexer.tokens.collect(&:token_type)
    assert_equal 2, engine.interpreter.subjects_count
    assert_equal 2, engine.interpreter.sheets.count
  end

  test "should parse identifier variable at event" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large_number at event-two >= 20")
    assert_equal [:identifier, :at, :identifier, :greater_equal, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 1, engine.interpreter.subjects_count
    assert_equal 1, engine.interpreter.sheets.count
  end

  test "should parse identifier variable at event with @ symbol" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large_number @ event-two >= 20")
    assert_equal [:identifier, :at, :identifier, :greater_equal, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 1, engine.interpreter.subjects_count
    assert_equal 1, engine.interpreter.sheets.count
  end

  test "should only include results across same sheets of a design when ORing" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large_number is 100 or animals is 3")
    assert_equal [:identifier, :equal, :number, :or, :identifier, :equal, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 1, engine.interpreter.subjects_count
    assert_equal 2, engine.interpreter.sheets.count
  end

  test "should not include results across same sheets of a design" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large_number is 100 and animals is 3")
    assert_equal [:identifier, :equal, :number, :and, :identifier, :equal, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 0, engine.interpreter.subjects_count
    assert_equal 0, engine.interpreter.sheets.count
  end

  test "should include results if they exist on the same subject sheet of a design" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large_number is 100 and animals is 2")
    assert_equal [:identifier, :equal, :number, :and, :identifier, :equal, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 1, engine.interpreter.subjects_count
    assert_equal 1, engine.interpreter.sheets.count
  end

  # Test design at event is present.
  test "should parse identifier design at event is entered" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large-number at event-one is entered")
    assert_equal [:identifier, :at, :identifier, :equal, :entered], engine.lexer.tokens.collect(&:token_type)
    assert_equal 6, engine.interpreter.subjects_count
    assert_equal 6, engine.interpreter.sheets.count
  end

  test "should parse identifier design at event is present" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large-number at event-one is present")
    assert_equal [:identifier, :at, :identifier, :equal, :present], engine.lexer.tokens.collect(&:token_type)
    assert_equal 5, engine.interpreter.subjects_count
    assert_equal 5, engine.interpreter.sheets.count
  end

  test "should parse identifier design at event is missing" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large-number at event-one is missing")
    assert_equal [:identifier, :at, :identifier, :equal, :missing], engine.lexer.tokens.collect(&:token_type)
    assert_equal 2, engine.interpreter.subjects_count
    assert_equal 1, engine.interpreter.sheets.count
  end

  test "should parse identifier design at event is unentered" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("large-number at event-one is unentered")
    assert_equal [:identifier, :at, :identifier, :equal, :unentered], engine.lexer.tokens.collect(&:token_type)
    assert_equal 1, engine.interpreter.subjects_count
    assert_equal 0, engine.interpreter.sheets.count
  end

  # Test should return results for checkbox variables
  test "should return results for favorite genres includes action" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("favorite_genres is 1")
    assert_equal [:identifier, :equal, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 1, engine.interpreter.subjects_count
    assert_equal 1, engine.interpreter.sheets.count
  end

  test "should return results for favorite genres includes romance" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("favorite_genres is 7")
    assert_equal [:identifier, :equal, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 2, engine.interpreter.subjects_count
    assert_equal 2, engine.interpreter.sheets.count
  end

  test "should return results for favorite genres includes action and romance" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("favorite_genres is 1 and favorite_genres is 7")
    assert_equal [:identifier, :equal, :number, :and, :identifier, :equal, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 1, engine.interpreter.subjects_count
    assert_equal 1, engine.interpreter.sheets.count
  end

  test "should return results for favorite genres includes action or drama" do
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("favorite_genres is 1 or favorite_genres is 4")
    assert_equal [:identifier, :equal, :number, :or, :identifier, :equal, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 2, engine.interpreter.subjects_count
    assert_equal 2, engine.interpreter.sheets.count
  end

  test "should return results for favorite genres that do not include romance" do
    # TODO: Determine what this is expected to return. Should it include a sheet
    # that has other responses alongside romance, or disregard that completely?
    skip
    engine = Engine::Engine.new(projects(:engine), users(:engine_editor))
    engine.run("favorite_genres != 7")
    assert_equal [:identifier, :bang_equal, :number], engine.lexer.tokens.collect(&:token_type)
    assert_equal 2, engine.interpreter.subjects_count
    assert_equal 2, engine.interpreter.sheets.count
    puts "includes romance (correct1, correct2)"
    puts engine.interpreter.sheets.collect { |s| s.subject.name }
  end

  test "should parse subject is randomized" do
    engine = Engine::Engine.new(projects(:two), users(:regular))
    engine.run("subject is randomized")
    assert_equal [:subject, :equal, :randomized], engine.lexer.tokens.collect(&:token_type)
    assert_equal 10, engine.interpreter.subjects_count
  end
end
