# frozen_string_literal: true

module Validation
  module Validators
    class TimeOfDay < Validation::Validators::Default
      def messages
        {
          blank: "",
          invalid: I18n.t("validators.time_of_day_invalid"),
          out_of_range: I18n.t("validators.time_of_day_out_of_range"),
          in_hard_range: I18n.t("validators.time_of_day_in_hard_range"),
          in_soft_range: ""
        }
      end

      def message(value)
        full_message = messages[status(value).to_sym]
        time_of_day = parse_time_of_day_from_hash(value)
        if time_of_day
          prepend = if time_of_day[:hours_24] == 12 && time_of_day[:minutes].zero? && time_of_day[:seconds].zero?
                      I18n.t("sheets.at_noon")
                    elsif time_of_day[:hours_24].zero? && time_of_day[:minutes].zero? && time_of_day[:seconds].zero?
                      I18n.t("sheets.at_midnight")
                    elsif time_of_day[:hours_24] < 12
                      I18n.t("sheets.in_the_morning")
                    elsif time_of_day[:hours_24] < 17
                      I18n.t("sheets.in_the_afternoon")
                    elsif time_of_day[:hours_24] < 22
                      I18n.t("sheets.in_the_evening")
                    else
                      I18n.t("sheets.at_night")
                    end
          full_message = prepend + full_message
        end
        full_message
      end

      def blank_value?(value)
        value[:hours].blank? && value[:minutes].blank? && value[:seconds].blank?
      rescue
        true
      end

      def invalid_format?(value)
        !blank_value?(value) && !parse_time_of_day_from_hash(value)
      end

      def formatted_value(value)
        hash = parse_time_of_day_from_hash(value)
        minutes = format("%02d", hash[:minutes])
        seconds = format("%02d", hash[:seconds])
        if @variable.twelve_hour_clock?
          if @variable.show_seconds?
            "#{hash[:hours]}:#{minutes}:#{seconds} #{hash[:period]}"
          else
            "#{hash[:hours]}:#{minutes} #{hash[:period]}"
          end
        else
          if @variable.show_seconds?
            "#{format("%02d", hash[:hours_24])}:#{minutes}:#{seconds}"
          else
            "#{format("%02d", hash[:hours_24])}:#{minutes}"
          end
        end
      rescue
        nil
      end

      def show_full_message?(_value)
        true
      end

      def response_to_value(response)
        if response.is_a?(Hash)
          response[:hours] = parse_integer(response[:hours])
          response[:minutes] = parse_integer(response[:minutes])
          response[:seconds] = parse_integer(response[:seconds])
          response
        else
          time = parse_time_of_day(response)
          if @variable.twelve_hour_clock?
            (time ? { hours: time[:hours], minutes: time[:minutes], seconds: time[:seconds], period: time[:period] } : { period: @variable.time_of_day_format == "12hour-pm" ? "pm" : "am" })
          else
            (time ? { hours: time[:hours_24], minutes: time[:minutes], seconds: time[:seconds] } : {})
          end
        end
      end

      def db_key_value_pairs(response)
        { value: parse_time_of_day_from_hash_to_s(response) }
      end
    end
  end
end
