# frozen_string_literal: true

module Validation
  module Validators
    class TimeDuration < Validation::Validators::Default
      def messages
        {
          blank: "",
          invalid: I18n.t("validators.time_duration_invalid"),
          out_of_range: I18n.t("validators.time_duration_out_of_range"),
          in_hard_range: I18n.t("validators.time_duration_in_hard_range"),
          in_soft_range: ""
        }
      end

      def blank_value?(value)
        value[:hours].blank? && value[:minutes].blank? && value[:seconds].blank?
      rescue
        true
      end

      def invalid_format?(value)
        !blank_value?(value) && !parse_time_duration_from_hash(value, no_hours: @variable.no_hours?)
      end

      def formatted_value(value)
        hash = parse_time_duration_from_hash(value, no_hours: @variable.no_hours?)
        h = (hash[:hours] == 1 ? I18n.t("sheets.hour") : I18n.t("sheets.hours"))
        m = (hash[:minutes] == 1 ? I18n.t("sheets.minute") : I18n.t("sheets.minutes"))
        s = (hash[:seconds] == 1 ? I18n.t("sheets.second") : I18n.t("sheets.seconds"))
        case @variable.time_duration_format
        when "mm:ss"
          "#{hash[:minutes]} #{m} #{hash[:seconds]} #{s}"
        when "hh:mm"
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
          time = parse_time_duration(response, no_hours: @variable.no_hours?)
          (time ? { hours: time[:hours], minutes: time[:minutes], seconds: time[:seconds] } : {})
        end
      end

      def db_key_value_pairs(response)
        { value: parse_time_duration_from_hash_to_s(response, no_hours: @variable.no_hours?) }
      end
    end
  end
end
