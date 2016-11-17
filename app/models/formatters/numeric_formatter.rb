# frozen_string_literal: true

module Formatters
  # Used to help format arrays of database responses for numeric variables.
  class NumericFormatter < DomainFormatter
    def raw_response(response)
      domain_option = domain_options.find_by(value: response)
      if domain_option
        domain_option.value
      else
        Float(response)
      end
    rescue
      response
    end
  end
end
