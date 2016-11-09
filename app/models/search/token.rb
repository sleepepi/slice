# frozen_string_literal: true

# Defines a single search parameter.
class Token
  def self.parse(part)
    new.parse(part)
  end

  attr_accessor :key, :operator, :value

  def initialize
    @operator = nil
    @key = nil
    @value = nil
  end

  def parse(part)
    (@key, @value) = part.split(':')
    if @value.blank?
      @value = @key
      @key = 'search'
    elsif %w(has is).include?(@key)
      @key = @value
      @value = '1'
      @operator = '='
    elsif %w(not).include?(@key)
      @key = @value
      @value = '1'
      @operator = '!='
    else
      @operator = set_operator
      @value = @value.gsub(/^#{operator}/, '') unless @operator.nil?
    end
    self
  end

  def to_hash
    { key: @key, operator: @operator, value: @value }
  end

  def to_s
    case @key
    when 'search'
      @value
    when 'randomized'
      "#{@operator == '=' ? 'is' : 'not'}:randomized"
    when 'adverse-events'
      "adverse-events:#{@value}"
    else
      "#{@key}:#{@operator}#{@value}"
    end
  end

  private

  def set_operator
    operator = nil
    found = (/^>=|^<=|^>|^=|^<|^!=|^entered$|^present$|^any$|^missing$|^unentered$|^blank$/).match(@value)
    operator = found[0] if found
    operator
  end
end
