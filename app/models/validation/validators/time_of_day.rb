module Validation
  module Validators
    class TimeOfDay < Validation::Validators::Default

      MESSAGES = {
        blank: '',
        invalid: 'Not a Valid Time',
        out_of_range: 'Time Outside of Range',
        in_hard_range: 'Time Outside of Soft Range',
        in_soft_range: ''
      }

      def messages
        MESSAGES
      end

      def message(value)
        full_message = messages[status(value).to_sym]

        if time = get_time(value) and
          prepend = if time.hour == 12 and time.min == 0 and time.sec == 0
            "at noon"
          elsif time.hour == 0 and time.min == 0 and time.sec == 0
            "at midnight"
          elsif time.hour < 12
            "in the morning"
          elsif time.hour < 17
            "in the afternoon"
          else
            "in the evening"
          end
          full_message = prepend + full_message
        end

        full_message
      end

      def blank_value?(value)
        ((value[:hour].blank? and value[:minutes].blank? and value[:seconds].blank?) rescue true)
      end

      def invalid_format?(value)
        (!blank_value?(value) and !get_time(value))
      end

      def formatted_value(value)
        get_time(value).strftime("%-l:%M:%S %P") rescue nil
      end

      def response_to_value(response)
        if response.kind_of?(Hash)
          value = response
        else
          time = parse_time(response)
          (time ? { hour: time.hour, minutes: time.min, seconds: time.sec } : {})
        end
      end

      def db_key_value_pairs(response)
        hour = parse_integer(response[:hour])
        minutes = parse_integer(response[:minutes])
        seconds = parse_integer(response[:seconds])

        { response: parse_time_to_s("#{hour}:#{minutes}:#{seconds}", "") }
      end

    private

      def get_time(value)
        parse_time_from_hash(value)
      end

    end
  end
end
