# frozen_string_literal: true

module Validation
  module Validators
    # Used to help validate values for numeric variables.
    class Numeric < Validation::Validators::Default
      def messages
        {
          blank: "",
          invalid: I18n.t("validators.numeric_invalid"),
          out_of_range: I18n.t("validators.numeric_out_of_range"),
          in_hard_range: I18n.t("validators.numeric_in_hard_range"),
          in_soft_range: ""
        }
      end

      def message(value)
        domain_option = @variable.domain_options.find_by(value: value)
        if domain_option
          domain_option.value_and_name
        else
          messages[status(value).to_sym]
        end
      end

      def invalid_format?(value)
        !blank_value?(value) && !get_number(value)
      end

      def in_hard_range?(value)
        value_in_hard_range?(get_number(value)) || in_domain_options?(value)
      end

      def in_soft_range?(value)
        value_in_soft_range?(get_number(value)) || in_domain_options?(value)
      end

      def formatted_value(value)
        if in_domain_options?(value)
          ""
        else
          "#{value}#{" #{variable.units}" unless variable.units.blank?}" unless value.blank?
        end
      end

      def show_full_message?(value)
        message(value) != ""
      end

      private

      def get_number(value)
        string_response = format("%g", value)
        begin
          Integer(string_response)
        rescue
          Float(string_response)
        end
      rescue
        nil
      end

      def value_in_hard_range?(number)
        less_or_equal_to?(number, @variable.hard_maximum) && greater_than_or_equal_to?(number, @variable.hard_minimum)
      end

      def value_in_soft_range?(number)
        less_or_equal_to?(number, @variable.soft_maximum) && greater_than_or_equal_to?(number, @variable.soft_minimum)
      end

      def less_or_equal_to?(number, number_max)
        !number || !number_max || (number_max && number <= number_max)
      end

      def greater_than_or_equal_to?(number, number_min)
        !number || !number_min || (number_min && number >= number_min)
      end

      def in_domain_options?(value)
        @variable.domain_options.where(value: value).count > 0
      end
    end
  end
end
