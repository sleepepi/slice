# frozen_string_literal: true

module Validation
  module Validators
    class TimeOfDay < Validation::Validators::Default
      MESSAGES = {
        blank: '',
        invalid: 'Not a Valid Time of Day',
        out_of_range: 'Time of Day Outside of Range',
        in_hard_range: 'Time of Day Outside of Soft Range',
        in_soft_range: ''
      }

      def messages
        MESSAGES
      end

      def message(value)
        full_message = messages[status(value).to_sym]
        time_of_day = parse_time_of_day_from_hash(value)
        if time_of_day
          prepend = if time_of_day[:hours_24] == 12 && time_of_day[:minutes].zero? && time_of_day[:seconds].zero?
                      'at noon'
                    elsif time_of_day[:hours_24].zero? && time_of_day[:minutes].zero? && time_of_day[:seconds].zero?
                      'at midnight'
                    elsif time_of_day[:hours_24] < 12
                      'in the morning'
                    elsif time_of_day[:hours_24] < 17
                      'in the afternoon'
                    else
                      'in the evening'
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
        minutes = format('%02d', hash[:minutes])
        seconds = format('%02d', hash[:seconds])
        if @variable.twelve_hour_clock?
          if @variable.show_seconds?
            "#{hash[:hours]}:#{minutes}:#{seconds} #{hash[:period]}"
          else
            "#{hash[:hours]}:#{minutes} #{hash[:period]}"
          end
        else
          if @variable.show_seconds?
            "#{format('%02d', hash[:hours_24])}:#{minutes}:#{seconds}"
          else
            "#{format('%02d', hash[:hours_24])}:#{minutes}"
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
            (time ? { hours: time[:hours], minutes: time[:minutes], seconds: time[:seconds], period: time[:period] } : { period: @variable.time_of_day_format == '12hour-pm' ? 'pm' : 'am' })
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
