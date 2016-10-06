# frozen_string_literal: true

module Validation
  module Validators
    class TimeDuration < Validation::Validators::Default
      MESSAGES = {
        blank: '',
        invalid: 'Not a Valid Time Duration',
        out_of_range: 'Time Duration Outside of Range',
        in_hard_range: 'Time Duration Outside of Soft Range',
        in_soft_range: ''
      }

      def messages
        MESSAGES
      end

      def blank_value?(value)
        value[:hours].blank? && value[:minutes].blank? && value[:seconds].blank?
      rescue
        true
      end

      def invalid_format?(value)
        !blank_value?(value) && !parse_time_duration_from_hash(value)
      end

      def formatted_value(value)
        hash = parse_time_duration_from_hash(value)
        h = (hash[:hours] == 1 ? 'hour' : 'hours')
        m = (hash[:minutes] == 1 ? 'minute' : 'minutes')
        s = (hash[:seconds] == 1 ? 'second' : 'seconds')
        case @variable.time_duration_format
        when 'mm:ss'
          "#{hash[:minutes]} #{m} #{hash[:seconds]} #{s}"
        when 'hh:mm'
          "#{hash[:hours]} #{h} #{hash[:minutes]} #{m}"
        else
          "#{hash[:hours]} #{h} #{hash[:minutes]} #{m} #{hash[:seconds]} #{s}"
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
          time = parse_time_duration(response)
          (time ? { hours: time[:hours], minutes: time[:minutes], seconds: time[:seconds] } : {})
        end
      end

      def db_key_value_pairs(response)
        { response: parse_time_duration_from_hash_to_s(response) }
      end
    end
  end
end
