module Validation
  module Validators
    class Date < Validation::Validators::Default

      MESSAGES = {
        blank: '',
        invalid: 'Not a Valid Date',
        out_of_range: 'Date Outside of Range',
        in_hard_range: 'Date Outside of Soft Range',
        in_soft_range: ''
      }

      def messages
        MESSAGES
      end

      def blank_value?(value)
        ((value[:month].blank? and value[:day].blank? and value[:year].blank?) rescue true)
      end

      def invalid_format?(value)
        (!blank_value?(value) and !get_date(value))
      end

      def in_hard_range?(value)
        date_in_hard_range?(get_date(value))
      end

      def in_soft_range?(value)
        date_in_soft_range?(get_date(value))
      end

      def formatted_value(value)
        get_date(value).strftime("%B %-d, %Y") rescue nil
      end

      def response_to_value(response)
        if response.kind_of?(Hash)
          response
        else
          # This parses the date from "%Y-%m-%d" database format
          date = (::Date.parse(response) rescue nil)
          (date ? { month: date.month, day: date.day, year: date.year } : {})
        end
      end

      def db_key_value_pairs(response)
        month = parse_integer(response[:month])
        day = parse_integer(response[:day])
        year = parse_integer(response[:year])

        # Save valuable to string in "%Y-%m-%d" db format, passing in a date
        { response: parse_date("#{month}/#{day}/#{year}") }
      end

    private

      def get_date(value)
        parse_date_from_hash(value)
      end

      def date_in_hard_range?(date)
        less_or_equal_to_date?(date, @variable.date_hard_maximum) and greater_than_or_equal_to_date?(date, @variable.date_hard_minimum)
      end

      def date_in_soft_range?(date)
        less_or_equal_to_date?(date, @variable.date_soft_maximum) and greater_than_or_equal_to_date?(date, @variable.date_soft_minimum)
      end

      def less_or_equal_to_date?(date, date_max)
        !date or !date_max or (date_max and date <= date_max)
      end

      def greater_than_or_equal_to_date?(date, date_min)
        !date or !date_min or (date_min and date >= date_min)
      end

    end
  end
end
