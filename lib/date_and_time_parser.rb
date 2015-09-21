module DateAndTimeParser

  def parse_date(date_string, default_date = nil)
    date_string.to_s.split('/', -1).last.size == 2 ? Date.strptime(date_string, "%m/%d/%y") : Date.strptime(date_string, "%m/%d/%Y") rescue default_date
  end

  def parse_date_from_hash(date_hash)
    if date_hash.is_a?(Hash)
      month = parse_integer(date_hash[:month])
      day = parse_integer(date_hash[:day])
      year = parse_integer(date_hash[:year])
      parse_date("#{month}/#{day}/#{year}")
    else
      parse_date("")
    end
  end

  def parse_time(time_string, default_time = nil)
    time_string.to_s.split(':', -1).last.size > 0 ? Time.strptime(time_string, "%H:%M:%S") : Time.strptime(time_string, "%H:%M:") rescue default_time
  end

  def parse_time_to_s(time_string, default_time = '')
    parse_time(time_string, default_time).strftime("%H:%M:%S") rescue default_time
  end

  def parse_time_from_hash(time_hash)
    if time_hash.is_a?(Hash)
      hour = parse_integer(time_hash[:hour])
      minutes = parse_integer(time_hash[:minutes])
      seconds = parse_integer(time_hash[:seconds])
      parse_time("#{hour}:#{minutes}:#{seconds}")
    else
      parse_time("")
    end
  end

  def parse_integer(string)
    begin
      Integer("%g" % string)
    rescue
      nil
    end
  end

end
