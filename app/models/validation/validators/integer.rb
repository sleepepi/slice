# frozen_string_literal: true

module Validation
  module Validators
    # Used to help validate values for integer variables.
    class Integer < Validation::Validators::Numeric
      def messages
        {
          blank: "",
          invalid: I18n.t("validators.integer_invalid"),
          out_of_range: I18n.t("validators.integer_out_of_range"),
          in_hard_range: I18n.t("validators.integer_in_hard_range"),
          in_soft_range: ""
        }
      end

      private

      def get_number(value)
        value = value.gsub(/^([-+]?)(0*)/, "\\1") if value.is_a?(String) && value.strip != "0"
        Integer(format("%d", value))
      rescue
        nil
      end
    end
  end
end
