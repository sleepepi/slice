# frozen_string_literal: true

module Validation
  module Validators
    class Date < Validation::Validators::Default
      def messages
        {
          blank: "",
          invalid: I18n.t("validators.date_invalid"),
          out_of_range: I18n.t("validators.date_out_of_range"),
          in_hard_range: I18n.t("validators.date_in_hard_range"),
          in_soft_range: ""
        }
      end

      def blank_value?(value)
        value[:month].blank? && value[:day].blank? && value[:year].blank?
      rescue
        true
      end

      def invalid_format?(value)
        (!blank_value?(value) && !get_date(value))
      end

      def in_hard_range?(value)
        date_in_hard_range?(get_date(value))
      end

      def in_soft_range?(value)
        date_in_soft_range?(get_date(value))
      end

      def formatted_value(value)
        get_date(value).strftime("%B %-d, %Y")
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
          # This parses the date from "%Y-%m-%d" database format
          date = begin
            ::Date.strptime(response, "%Y-%m-%d")
          rescue
            nil
          end
          (date ? { month: date.month, day: date.day, year: date.year } : {})
        end
      end

      def db_key_value_pairs(response)
        { value: parse_date_from_hash_to_s(response) }
      end

      private

      def get_date(value)
        parse_date_from_hash(value)
      end

      def date_in_hard_range?(date)
        less_or_equal_to_date?(date, @variable.date_hard_maximum) &&
          greater_than_or_equal_to_date?(date, @variable.date_hard_minimum) &&
          (less_or_equal_to_date?(date, Time.zone.today) || !@variable.disallow_future_dates?)
      end

      def date_in_soft_range?(date)
        less_or_equal_to_date?(date, @variable.date_soft_maximum) &&
          greater_than_or_equal_to_date?(date, @variable.date_soft_minimum)
      end

      def less_or_equal_to_date?(date, date_max)
        !date || !date_max || (date_max && date <= date_max)
      end

      def greater_than_or_equal_to_date?(date, date_min)
        !date || !date_min || (date_min && date >= date_min)
      end
    end
  end
end
