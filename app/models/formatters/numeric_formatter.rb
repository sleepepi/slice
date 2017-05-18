# frozen_string_literal: true

module Formatters
  # Used to help format arrays of database responses for numeric variables.
  class NumericFormatter < DomainFormatter
    def raw_response(response, shared_responses = domain_options)
      domain_option = shared_responses.find { |option| option.value == response }
      if domain_option
        domain_option.value
      elsif response.blank?
        response
      else
        Float(response)
      end
    rescue
      response
    end
  end
end
