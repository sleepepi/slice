module DateAndTimeParser

  def parse_date(date_string, default_date = '')
    date_string.to_s.split('/', -1).last.size == 2 ? Date.strptime(date_string, "%m/%d/%y") : Date.strptime(date_string, "%m/%d/%Y") rescue default_date
  end

  def parse_time(time_string, default_time = '')
    time_string.to_s.split(':', -1).last.size > 0 ? Time.strptime(time_string, "%H:%M:%S") : Time.strptime(time_string, "%H:%M:") rescue default_time
  end

  def parse_time_to_s(time_string, default_time = '')
    parse_time(time_string, default_time).strftime("%H:%M:%S") rescue default_time
  end

  def parse_integer(string)
    begin
      Integer("%g" % string)
    rescue
      nil
    end
  end

end
