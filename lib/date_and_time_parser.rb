module DateAndTimeParser

  def parse_date(date_string, default_date = '')
    date_string.to_s.split('/').last.size == 2 ? Date.strptime(date_string, "%m/%d/%y") : Date.strptime(date_string, "%m/%d/%Y") rescue default_date
  end

  def parse_time(time_string, default_time = '')
    Time.parse(time_string).strftime('%H:%M:%S') rescue default_time
  end

  def parse_integer(string)
    begin
      Integer("%g" % string)
    rescue
      nil
    end
  end

end
