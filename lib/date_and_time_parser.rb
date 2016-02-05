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
    hash = nil
    sections = time_duration_string.to_s.split(':')
    hours = parse_integer(sections[0])
    minutes = parse_integer(sections[1])
    seconds = parse_integer(sections[2])
    if hours || minutes || seconds
      hash = {}
      hash[:hours]   = hours   || 0
      hash[:minutes] = minutes || 0
      hash[:seconds] = seconds || 0
    end
    hash
  end

  def parse_time_duration_from_hash(time_duration_hash)
    if time_duration_hash.is_a? Hash
      Rails.logger.debug time_duration_hash.inspect
      hours = parse_integer(time_duration_hash[:hours])
      minutes = parse_integer(time_duration_hash[:minutes])
      seconds = parse_integer(time_duration_hash[:seconds])
      Rails.logger.debug "#{hours}:#{minutes}:#{seconds}"
      parse_time_duration("#{hours}:#{minutes}:#{seconds}")
    else
      parse_time_duration('')
    end
  end

  def parse_time_duration_from_hash_to_s(time_duration_hash, default_time_duration: '')
    hash = parse_time_duration_from_hash(time_duration_hash)
    "#{hash[:hours]}:#{hash[:minutes]}:#{hash[:seconds]}"
  rescue
    default_time_duration
  end

  def parse_integer(string)
    Integer(format('%g', string))
  rescue
    nil
  end
end
