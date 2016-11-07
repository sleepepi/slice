# frozen_string_literal: true

# Helps parse dates and times in different formats to Ruby objects
module DateAndTimeParser
  def parse_date(date_string, default_date = nil)
    if date_string.to_s.split('/', -1).last.size == 2
      Date.strptime(date_string, '%m/%d/%y')
    else
      Date.strptime(date_string, '%m/%d/%Y')
    end
  rescue
    default_date
  end

  def parse_date_from_hash(date_hash)
    if date_hash.is_a?(Hash)
      month = parse_integer(date_hash[:month])
      day = parse_integer(date_hash[:day])
      year = parse_integer(date_hash[:year])
      parse_date("#{month}/#{day}/#{year}")
    else
      parse_date('')
    end
  end

  # String is returned in database format '%Y-%m-%d'
  def parse_date_from_hash_to_s(date_hash, default_date = '')
    parse_date_from_hash(date_hash).strftime('%Y-%m-%d')
  rescue
    default_date
  end

  def parse_time(time_string, default_time = nil)
    if time_string.to_s.split(':', -1).last.size > 0
      Time.strptime(time_string, '%H:%M:%S')
    else
      Time.strptime(time_string, '%H:%M:')
    end
  rescue
    default_time
  end

  # String is returned in database format '%H:%M:%S'
  def parse_time_to_s(time_string, default_time = '')
    parse_time(time_string, default_time).strftime('%H:%M:%S')
  rescue
    default_time
  end

  def parse_time_from_hash(time_hash)
    if time_hash.is_a?(Hash)
      hour = parse_integer(time_hash[:hour])
      if %w(am pm).include?(time_hash[:period]) && hour
        hour = nil if hour < 1 || hour > 12
        if hour
          hour += 12 if time_hash[:period] == 'pm' && hour != 12
          hour = 0 if time_hash[:period] == 'am' && hour == 12
        end
      end
      minutes = parse_integer(time_hash[:minutes])
      seconds = parse_integer(time_hash[:seconds])
      parse_time("#{hour}:#{minutes}:#{seconds}")
    else
      parse_time('')
    end
  end

  # String is returned in database format '%H:%M:%S'
  def parse_time_from_hash_to_s(time_hash, default_time = '')
    parse_time_from_hash(time_hash).strftime('%H:%M:%S')
  rescue
    default_time
  end

  def parse_time_duration(time_duration_string)
    total_seconds = parse_integer(time_duration_string)
    hms_hash(total_seconds)
  end

  def parse_time_duration_from_hash(time_duration_hash)
    return unless time_duration_hash.is_a?(Hash)
    hours = parse_integer(time_duration_hash[:hours])
    minutes = parse_integer(time_duration_hash[:minutes])
    seconds = parse_integer(time_duration_hash[:seconds])
    if hours || minutes || seconds
      total_seconds = ((hours || 0).abs * 3600 + (minutes || 0).abs * 60 + (seconds || 0).abs)
      hms_hash(total_seconds)
    end
  end

  def parse_time_duration_from_hash_to_s(time_duration_hash, default_time_duration: '')
    hash = parse_time_duration_from_hash(time_duration_hash)
    hash[:total_seconds].to_s
  rescue
    default_time_duration
  end

  # TODO: Remove in v0.46.0
  def parse_time_duration_deprecated(time_duration_string)
    sections = time_duration_string.to_s.split(':')
    hours = parse_integer(sections[0])
    minutes = parse_integer(sections[1])
    seconds = parse_integer(sections[2])
    hms_hash_deprecated(hours, minutes, seconds)
  end

  def parse_time_duration_from_hash_deprecated(time_duration_hash)
    return unless time_duration_hash.is_a?(Hash)
    hours = parse_integer(time_duration_hash[:hours])
    minutes = parse_integer(time_duration_hash[:minutes])
    seconds = parse_integer(time_duration_hash[:seconds])
    hms_hash_deprecated(hours, minutes, seconds)
  end

  def parse_time_duration_from_hash_to_s_deprecated(time_duration_hash, default_time_duration: '')
    hash = parse_time_duration_from_hash(time_duration_hash)
    "#{hash[:hours]}:#{hash[:minutes]}:#{hash[:seconds]}"
  rescue
    default_time_duration
  end
  # END

  def parse_integer(string)
    Integer(format('%g', string))
  rescue
    nil
  end

  def parse_imperial_height(imperial_height_string)
    total_inches = parse_integer(imperial_height_string)
    feet_inches_hash(total_inches)
  end

  def parse_imperial_height_from_hash(imperial_height_hash)
    return unless imperial_height_hash.is_a?(Hash)
    feet = parse_integer(imperial_height_hash[:feet])
    inches = parse_integer(imperial_height_hash[:inches])
    if feet || inches
      total_inches = ((feet || 0).abs * 12 + (inches || 0).abs) * ((feet || 0).negative? ? -1 : 1)
      feet_inches_hash(total_inches)
    end
  end

  def parse_imperial_height_from_hash_to_s(imperial_height_hash, default_imperial_height: '')
    hash = parse_imperial_height_from_hash(imperial_height_hash)
    hash[:total_inches].to_s
  rescue
    default_imperial_height
  end

  def parse_imperial_weight(imperial_weight_string)
    total_ounces = parse_integer(imperial_weight_string)
    pounds_ounces_hash(total_ounces)
  end

  def parse_imperial_weight_from_hash(imperial_weight_hash)
    return unless imperial_weight_hash.is_a?(Hash)
    pounds = parse_integer(imperial_weight_hash[:pounds])
    ounces = parse_integer(imperial_weight_hash[:ounces])
    if pounds || ounces
      total_ounces = ((pounds || 0).abs * 16 + (ounces || 0).abs) * ((pounds || 0).negative? ? -1 : 1)
      pounds_ounces_hash(total_ounces)
    end
  end

  def parse_imperial_weight_from_hash_to_s(imperial_weight_hash, default_imperial_weight: '')
    hash = parse_imperial_weight_from_hash(imperial_weight_hash)
    hash[:total_ounces].to_s
  rescue
    default_imperial_weight
  end

  private

  # TODO: Remove in v0.46.0
  def hms_hash_deprecated(hours, minutes, seconds)
    return unless hours || minutes || seconds
    hash = {}
    hash[:hours]   = hours   || 0
    hash[:minutes] = minutes || 0
    hash[:seconds] = seconds || 0
    hash
  end
  # END TODO

  def hms_hash(total_seconds)
    return unless total_seconds
    hours = total_seconds.abs / 3600
    minutes = (total_seconds.abs - hours * 3600) / 60
    seconds = total_seconds.abs % 60
    hash = {}
    hash[:hours] = hours
    hash[:minutes] = minutes
    hash[:seconds] = seconds
    hash[:total_seconds] = total_seconds
    hash
  end

  def feet_inches_hash(total_inches)
    return unless total_inches
    feet = (total_inches.abs / 12) * (total_inches.negative? ? -1 : 1)
    inches = total_inches.abs % 12
    hash = {}
    hash[:feet]   = feet   || 0
    hash[:inches] = inches || 0
    hash[:total_inches] = total_inches
    hash
  end

  def pounds_ounces_hash(total_ounces)
    return unless total_ounces
    pounds = (total_ounces.abs / 16) * (total_ounces.negative? ? -1 : 1)
    ounces = total_ounces.abs % 16
    hash = {}
    hash[:pounds] = pounds || 0
    hash[:ounces] = ounces || 0
    hash[:total_ounces] = total_ounces
    hash
  end
end
