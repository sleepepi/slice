# frozen_string_literal: true

module Validation
  module Validators
    class ImperialHeight < Validation::Validators::Default
      MESSAGES = {
        blank: '',
        invalid: 'Not a Valid Height',
        out_of_range: 'Height Outside of Range',
        in_hard_range: 'Height Outside of Soft Range',
        in_soft_range: ''
      }

      def messages
        MESSAGES
      end

      def blank_value?(value)
        value[:feet].blank? && value[:inches].blank?
      rescue
        true
      end

      def invalid_format?(value)
        !blank_value?(value) && !parse_imperial_height_from_hash(value)
      end

      def formatted_value(value)
        hash = parse_imperial_height_from_hash(value)
        f = (hash[:feet] == 1 ? 'foot' : 'feet')
        i = (hash[:inches] == 1 ? 'inch' : 'inches')
        "#{hash[:feet]} #{f} #{hash[:inches]} #{i}"
      rescue
        nil
      end

      def show_full_message?(_value)
        true
      end

      def response_to_value(response)
        if response.is_a? Hash
          response[:feet] = parse_integer(response[:feet])
          response[:inches] = parse_integer(response[:inches])
          response
        else
          height = parse_imperial_height(response)
          (height ? { feet: height[:feet], inches: height[:inches] } : {})
        end
      end

      def db_key_value_pairs(response)
        { response: parse_imperial_height_from_hash_to_s(response) }
      end
    end
  end
end
