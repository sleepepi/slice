# frozen_string_literal: true

# Defines a single search parameter.
class Token
  include DateAndTimeParser

  def self.parse(part)
    new.parse(part)
  end

  attr_accessor :key, :operator, :value

  def initialize(key: nil, operator: nil, value: nil)
    @key = key
    @operator = operator
    @value = value
    @has_quotes = false
    @core_values = []
  end

  def parse(part)
    (@key, @value) = part.split(':', 2)
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

  def convert_value(val, variable)
    return val unless variable
    core_value = \
      case variable.variable_type
      when 'time_duration'
        convert_time_duration(val)
      when 'time'
        convert_time_of_day(val)
      when 'imperial_height'
        convert_imperial_height(val)
      when 'imperial_weight'
        convert_imperial_weight(val)
      else
        val
      end
    @core_values << core_value
    core_value
  end

  def convert_imperial_weight(val)
    if !(/^(\d+)oz$/ =~ val).nil?
      val.gsub(/oz$/, '')
    elsif !(/^(\d+)lb$/ =~ val).nil?
      (val.gsub(/lb$/, '').to_i * 16).to_s
    else
      val
    end
  end

  def convert_imperial_height(val)
    if !(/^(\d+)in$/ =~ val).nil?
      val.gsub(/in$/, '')
    elsif !(/^(\d+)ft$/ =~ val).nil?
      (val.gsub(/ft$/, '').to_i * 12).to_s
    else
      val
    end
  end

  def convert_time_duration(val)
    original_value = val
    hours = nil
    minutes = nil
    seconds = nil
    if val.split('h', 2).size == 2
      (hours, val) = val.split('h', 2)
      hours = parse_integer(hours)
    end

    if val.split('m', 2).size == 2
      (minutes, val) = val.split('m', 2)
      minutes = parse_integer(minutes)
    end

    if val.split('s', 2).size == 2
      (seconds, val) = val.split('s', 2)
      seconds = parse_integer(seconds)
    end

    if hours || minutes || seconds
      ((hours || 0) * 3600 + (minutes || 0) * 60 + (seconds || 0)).to_s
    else
      original_value
    end
  end

  # 12am, 12pm, 12:01am, 12:00:01am, 13:00:00, 1:00pm, 1pm, 1p 1a
  def convert_time_of_day(val)
    return val unless parse_integer(val).nil?
    if val == 'noon'
      val = '12pm'
    elsif val == 'midnight'
      val = '12am'
    elsif !(/a$/ =~ val).nil?
      val.gsub!(/a$/, 'am')
    elsif !(/p$/ =~ val).nil?
      val.gsub!(/p$/, 'pm')
    end
    hours = parse_integer(Time.zone.parse(val).strftime('%H'))
    minutes = parse_integer(Time.zone.parse(val).strftime('%M'))
    seconds = parse_integer(Time.zone.parse(val).strftime('%S'))
    (hours * 3600 + minutes * 60 + seconds).to_s
  rescue
    val
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
