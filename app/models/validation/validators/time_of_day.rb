# frozen_string_literal: true

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
        time = get_time(value)
        if time
          prepend = if time.hour == 12 && time.min == 0 && time.sec == 0
                      'at noon'
                    elsif time.hour == 0 && time.min == 0 && time.sec == 0
                      'at midnight'
                    elsif time.hour < 12
                      'in the morning'
                    elsif time.hour < 17
                      'in the afternoon'
                    else
                      'in the evening'
                    end
          full_message = prepend + full_message
        end
        full_message
      end

      def blank_value?(value)
        value[:hour].blank? && value[:minutes].blank? && value[:seconds].blank?
      rescue
        true
      end

      def invalid_format?(value)
        !blank_value?(value) && !get_time(value)
      end

      def formatted_value(value)
        if @variable.show_seconds?
          get_time(value).strftime('%-l:%M:%S %P')
        else
          get_time(value).strftime('%-l:%M %P')
        end
      rescue
        nil
      end

      def show_full_message?(_value)
        true
      end

      def response_to_value(response)
        if response.is_a?(Hash)
          response
        else
          time = parse_time(response)
          if @variable.format == '12hour'
            (time ? { hour: time.strftime('%I').to_i, minutes: time.min, seconds: time.sec, period: time.strftime('%P') } : {})
          else
            (time ? { hour: time.hour, minutes: time.min, seconds: time.sec } : {})
          end
        end
      end

      def db_key_value_pairs(response)
        { response: parse_time_from_hash_to_s(response) }
      end

      private

      def get_time(value)
        parse_time_from_hash(value)
      end
    end
  end
end
