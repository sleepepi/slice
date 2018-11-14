# frozen_string_literal: true

module Formatters
  # Used to help format arrays of database responses for integer variables.
  class IntegerFormatter < NumericFormatter
    def raw_response(response, shared_responses = domain_options)
      domain_option = shared_responses.find { |option| option.value == response }
      if domain_option
        domain_option.value
      elsif response.blank?
        response
      else
        response = response.gsub(/^([-+]?)(0*)/, "\\1") if response.is_a?(String) && response.strip != "0"
        Integer(format("%d", response))
      end
    rescue
      response
    end
  end
end
