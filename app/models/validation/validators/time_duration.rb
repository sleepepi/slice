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
        !blank_value?(value) && !get_time_duration(value)
      end

      def formatted_value(value)
        hash = get_time_duration(value)
        "#{hash[:hours]}h #{hash[:minutes]}' #{hash[:seconds]}\""
      rescue
        nil
      end

      def show_full_message?(_value)
        true
      end

      def response_to_value(response)
        if response.is_a? Hash
          response
        else
          time = parse_time_duration(response)
          (time ? { hours: time[:hours], minutes: time[:minutes], seconds: time[:seconds] } : {})
        end
      end

      def db_key_value_pairs(response)
        { response: parse_time_duration_from_hash_to_s(response) }
      end

      private

      def get_time_duration(value)
        parse_time_duration_from_hash(value)
      end
    end
  end
end
