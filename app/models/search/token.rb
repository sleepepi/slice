# frozen_string_literal: true

# Defines a single search parameter.
class Token
  def self.parse(part)
    new.parse(part)
  end

  attr_accessor :key, :operator, :value

  def initialize(key: nil, operator: nil, value: nil)
    @key = key
    @operator = operator
    @value = value
    @has_quotes = false
  end

  def parse(part)
    (@key, @value) = part.split(':')
    @value = remove_quotes(@value)
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

  def values
    if @has_quotes
      [@value]
    else
      @value.split(',')
    end
  end

  private

  def set_operator
    operator = nil
    found = (/^>=|^<=|^>|^=|^<|^!=|^entered$|^present$|^any$|^missing$|^unentered$|^blank$/).match(@value)
    operator = found[0] if found
    operator
  end

  def remove_quotes(old_value)
    new_value = old_value.to_s.gsub(/^"(.*?)"$/) { |m| $1 }
    @has_quotes = true if old_value.to_s.size != new_value.size
    new_value
  end
end
