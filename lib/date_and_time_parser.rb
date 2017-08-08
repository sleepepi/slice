# frozen_string_literal: true

# Helps parse dates and times in different formats to Ruby objects.
module DateAndTimeParser
  def parse_date(date_string, default_date = nil)
    if date_string.to_s.split("/", -1).last.size == 2
      Date.strptime(date_string, "%m/%d/%y")
    else
      Date.strptime(date_string, "%m/%d/%Y")
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
      parse_date("")
    end
  end

  # String is returned in database format "%Y-%m-%d"
  def parse_date_from_hash_to_s(date_hash, default_date = "")
    parse_date_from_hash(date_hash).strftime("%Y-%m-%d")
  rescue
    default_date
  end

  def parse_time_of_day(seconds_since_midnight_string)
    total_seconds_since_midnight = parse_integer(seconds_since_midnight_string)
    hmsampm_hash(total_seconds_since_midnight)
  end

  def parse_time_of_day_from_hash(time_of_day_hash)
    return unless time_of_day_hash.is_a?(Hash)
    hours = parse_integer(time_of_day_hash[:hours])
    minutes = parse_integer(time_of_day_hash[:minutes]) || 0
    seconds = parse_integer(time_of_day_hash[:seconds]) || 0
    period = time_of_day_hash[:period]
    if hours && ((period.blank? && hours.in?(0..23)) || (hours.in?(1..12))) && minutes.in?(0..59) && seconds.in?(0..59)
      if period == "pm"
        hours = (hours % 12) + 12
      elsif period == "am"
        hours = (hours % 12)
      end
      total_seconds_since_midnight = ((hours || 0).abs * 3600 + (minutes || 0).abs * 60 + (seconds || 0).abs)
      hmsampm_hash(total_seconds_since_midnight)
    end
  end

  def parse_time_of_day_from_hash_to_s(time_of_day_hash, default_time_of_day: "")
    hash = parse_time_of_day_from_hash(time_of_day_hash)
    hash[:total_seconds_since_midnight].to_s
  rescue
    default_time_of_day
  end

  def parse_time_duration(time_duration_string, no_hours: false)
    total_seconds = parse_integer(time_duration_string)
    hms_hash(total_seconds, no_hours: no_hours)
  end

  def parse_time_duration_from_hash(time_duration_hash, no_hours: false)
    return unless time_duration_hash.is_a?(Hash)
    hours = parse_integer(time_duration_hash[:hours])
    minutes = parse_integer(time_duration_hash[:minutes])
    seconds = parse_integer(time_duration_hash[:seconds])
    if hours || minutes || seconds
      total_seconds = ((hours || 0).abs * 3600 + (minutes || 0).abs * 60 + (seconds || 0).abs)
      hms_hash(total_seconds, no_hours: no_hours)
    end
  end

  def parse_time_duration_from_hash_to_s(time_duration_hash, default_time_duration: "", no_hours: false)
    hash = parse_time_duration_from_hash(time_duration_hash, no_hours: no_hours)
    hash[:total_seconds].to_s
  rescue
    default_time_duration
  end

  def parse_integer(string)
    Integer(format("%g", string))
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

  def parse_imperial_height_from_hash_to_s(imperial_height_hash, default_imperial_height: "")
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

  def parse_imperial_weight_from_hash_to_s(imperial_weight_hash, default_imperial_weight: "")
    hash = parse_imperial_weight_from_hash(imperial_weight_hash)
    hash[:total_ounces].to_s
  rescue
    default_imperial_weight
  end

  private

  def hmsampm_hash(total_seconds_since_midnight)
    return unless total_seconds_since_midnight
    return if total_seconds_since_midnight >= 24 * 3600
    hours = total_seconds_since_midnight.abs / 3600
    minutes = (total_seconds_since_midnight.abs - hours * 3600) / 60
    seconds = total_seconds_since_midnight.abs % 60
    hash = {}
    hash[:hours_24] = hours
    hash[:hours] = hours % 12
    hash[:hours] = 12 if hash[:hours].zero?
    hash[:minutes] = minutes
    hash[:seconds] = seconds
    hash[:period] = hours < 12 ? "am" : "pm"
    hash[:total_seconds_since_midnight] = total_seconds_since_midnight
    hash
  end

  def hms_hash(total_seconds, no_hours: false)
    return unless total_seconds
    hours = \
      if no_hours
        0
      else
        total_seconds.abs / 3600
      end
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
